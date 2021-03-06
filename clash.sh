CLASH_DIR=~/programfiles/clash
RJ_PATH=~/programfiles/rjsupplicant
WGET_LINK=\&log-level=info
RUIJIE_USER=12345
PASSWD=98765

login(){
  cd ${RJ_PATH}
  sudo ./rjsupplicant.sh -d 1 -n enx00e04a37770b -u ${RUIJIE_USER} -p ${PASSWD} && sudo service network-manager start
  w3m 2.2.2.2
}

update(){
  cd ${CLASH_DIR} 
  
  if [ $(env|grep -c "proxy") -eq 4 ];then
    unset HTTP_PROXY
	  unset http_proxy
	  unset HTTPS_PROXY
	  unset https_proxy
	  unset ALL_PROXY
  fi
  
  wget -O config.yml ${WGET_LINK} 2>&1 | tee tmp.log

  if [ $? -ne 0 ] ;then
      if [ $(cat tmp.log | grep "failed") -eq 1 ]; then
          echo "failed to create config.yml"
          return 0
      fi
      echo "no reason failed"
  fi

  if test -f 'config.yml' ;then
      if test -s config.yml ;then
          mv config.yml config.yaml
      else
          echo "config.yml is empty"
          update
      fi
  fi 
}

clash(){
  cd ${CLASH_DIR} 
  ./clash -d . 

  if test $? -eq 0 ;then
      echo "success"
  fi

  if [ $(env|grep -c "PROXY") -ne 3 ];then
          export HTTPS_PROXY=http://127.0.0.1:2345/
          export ALL_PROXY=socks://127.0.0.1:2345/
          export HTTP_PROXY=http://127.0.0.1:2345/
  fi

  if [ $(dpkg -l | grep w3m) ];then
      if [ $? -eq 0 ];then
          #选择延迟短的线路：正在实现
          w3m http://clash.razord.top/#/proxiesw
      else
          sudo apt install w3m
      fi
  fi
}
