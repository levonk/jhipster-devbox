#!/bin/sh

LIQUIBASE_VERSION="3.1.1"
function setupLiquibase(){
  source $HOME/.profile

  INSTALLED="$(command -v liquibase)"

  # if not added already
  if [ -z "$LIQUIBASE_HOME" ]
    then
      echo  'export MYSQL_JCONNECTOR=/usr/share/java/mysql-connector-java.jar'|sudo tee -a $HOME/.profile
      echo  'export LIQUIBASE_HOME=/usr/local/liquibase' |sudo tee -a $HOME/.profile
      echo  'export PATH=$PATH:$LIQUIBASE_HOME'|sudo tee -a $HOME/.profile
  fi

  if [ -z "$INSTALLED" ]
    then
        echo "Installing liquibase ${LIQUIBASE_VERSION}"
        sudo rm -rf liquibase*
        wget http://kaz.dl.sourceforge.net/project/liquibase/Liquibase%20Core/liquibase-"${LIQUIBASE_VERSION}"-bin.tar.gz
        gunzip liquibase-"$LIQUIBASE_VERSION"-bin.tar.gz
        sudo mkdir /usr/local/liquibase
        sudo tar -xf liquibase-"${LIQUIBASE_VERSION}"-bin.tar -C /usr/local/liquibase
        sudo chmod +x /usr/local/liquibase/liquibase
    else
        INSTALLED="$(liquibase --version)"
        echo "Liquibase is already installed, ${INSTALLED}"
  fi
}

setupLiquibase
