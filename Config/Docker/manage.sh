#!/bin/bash
echo "1.查看已经安装的站点"
echo "2.删除软件"

declare pick
read -p "请输入：" pick

declare path="/var/www"
echo "请输入站点安装地址,默认${path}"
read -p "请输入：" path

if [[ -z $path ]]; then
    path="/var/www"
elif ! [[ -d $path ]]; then
    echo "该地址不存在目录"
fi


case $pick in
'1')
  for i in "$path"/* ; do
      if [[ $i == "${path}/*" ]];then
        echo "该地址不存在站点"
      fi
      echo $i
  done
  ;;
'2')
  declare -a site_arr
  declare site_name
  declare site_number=0
  for i in "$path"/* ; do
      if [[ $i == "${path}/*" ]];then
        echo "该地址不存在站点"
        exit
      fi
      site_number=$(( site_number+1 ))
      site_name=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
      echo "${site_number}.${site_name}"
      site_arr[$site_number]=$site_name
  done
  read -p "请输入要删除的序号,多个用 空格 隔开：" site_name
  for i in $site_name ; do
      if [[ $i =~ [1-${#site_arr[*]}] ]]; then
          echo "开始删除 ${site_arr[$i]}"
          cd "$path/${site_arr[$i]}"
          docker compose down &> /dev/null && echo "站点已经停止运行"
          rm -rf "$path/${site_arr[$i]}" &> /dev/null
          echo "删除完成"
      fi
  done
  echo "删除完成"
  ;;
esac