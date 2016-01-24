#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail


#need: location of local app
#      location on server
#then need to:
#copy to a deploy dir to apply modifications
#add the following to the Gemfile:
#gem 'execjs'
#gem 'therubyracer'
#gem ‘mysql’

DEPLOY_AREA=/home/ger/tmp/deploy_area
REMOTE_MACHINE=gerardsw@gerardsweeney.com
REMOTE_RAILS_AREA=/home5/gerardsw/rails_apps

LOCAL_APP=$1
#SERVER_APP_ROOT=$2

if [ "$LOCAL_APP" == "" ] || [ ! -e "$LOCAL_APP" ]; then
  echo "Couldn't find local app dir: $LOCAL_APP"
  exit
fi

#if [ "$SERVER_APP_ROOT" == "" ]; then
#  echo "Must specify server app root"
#  exit
#fi

if [ ! -e $DEPLOY_AREA ]; then
  mkdir -p $DEPLOY_AREA || exit
fi

echo
echo
echo "Copying app to temp deploy area for local modifications..."

APP_NAME=`basename $LOCAL_APP`
rm -rf $DEPLOY_AREA/$APP_NAME
cp -r $LOCAL_APP $DEPLOY_AREA
pushd $DEPLOY_AREA

ls $APP_NAME

#replace sqlite3 with mysql
#sed -i -e 's/sqlite3/mysql/' $APP_NAME/Gemfile
#sed -i -e 's/postgresql/mysql/' $APP_NAME/Gemfile
sed -i -e '/execjs/d' $APP_NAME/Gemfile
sed -i -e '/therubyracer/d' $APP_NAME/Gemfile
sed -i -e '/mysql/d' $APP_NAME/Gemfile
sed -i -e '/sqlite3/d' $APP_NAME/Gemfile

#insert lines at the end
echo "gem 'execjs'" >> $APP_NAME/Gemfile
echo "gem 'therubyracer'" >> $APP_NAME/Gemfile
echo "gem 'mysql'" >> $APP_NAME/Gemfile

#create .htaccess file
cat > $APP_NAME/public/.htaccess <<END
Options -MultiViews
PassengerResolveSymlinksInDocumentRoot on
#Set this to whatever environment you'll be running in
RailsEnv production
RackBaseURI /
SetEnv GEM_HOME /home5/gerardsw/ruby/gems
END

#change production config to use mysql
sed -i -e '1,/^production:$/b' -e 's/sqlite3/mysql/g' $APP_NAME/config/database.yml
sed -i -e '1,/^production:$/b' -e 's/postgresql/mysql/g' $APP_NAME/config/database.yml
sed -i -e 's/MYUSERNAME/gerardsw_recipes/' -e 's/MYPASSWORD/passwd/' $APP_NAME/config/database.yml

echo; echo; echo; echo "Rsyncing data to remote host..."

rsync -v -e "ssh -v -v -v" --exclude ".git*" --exclude tmp --exclude .keep --stats -r $DEPLOY_AREA/$APP_NAME/ $REMOTE_MACHINE:$REMOTE_RAILS_AREA/$APP_NAME

echo; echo; echo; echo "Executing commands on remote host..."
ssh gerardsw@gerardsweeney.com "\
	cd $REMOTE_RAILS_AREA/$APP_NAME;\
	./bin/bundle install;\
	echo migrating db;\
	./bin/bundle exec rake db:migrate --trace RAILS_ENV=production;\
        echo precompiling assets;\
	RAILS_ENV=production rake assets:precompile;\
	touch tmp/restart.txt"

popd

