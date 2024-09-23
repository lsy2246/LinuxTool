#!/bin/bash
declare file_name=$(basename $0 .sh)
declare path_script=$1
declare pick
echo "========Automation========"
declare print_number=0
declare -a print_array
for i in "${path_script}/Config/${file_name}"/*;do
    print_number=$((print_number + 1))
    print_array[$print_number]=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    echo "${print_number}.${print_array[$print_number]}"
done
echo "输入其他任意返回主页"
echo "========Automation========"
read -p "请输入：" pick

if [[ ! ${pick} =~ [1-$print_number] ]];then
  exit
fi

read -p "请输入脚本存放路径(默认：/var/script)：" path

if [[ -z $path ]];then
  path='/var/script'
fi
mkdir -p "$path"

echo "执行日期"
echo "星号（*）：表示匹配任意值"
echo "逗号（,）：用于分隔多个值"
echo "斜线（/）：用于指定间隔值"
echo "连字符（-）：用于指定范围"

declare tmp_time
declare -a cron_array=("分钟" "小时" "天数" "月份" "星期" )
for i in "${cron_array[@]}";do
  read -p "${i}，默认为 * ：" tmp_time
  if [[ $tmp_time =~ ^[0-9]+$ || $tmp_time == '*' ]];then
    cron+="${tmp_time} "
  elif [[ -z ${tmp_time} ]];then
      cron+='* '
  else
    echo "输入错误"
    exit
  fi
done
if [[ "$cron" == '* * * * * ' ]];then
   read "该脚本会无时无刻执行，请重新输入"
   exit
fi

if [[ -f "${path_script}/Config/${file_name}/${print_array[pick]}.sh" ]];then
  echo "该路径文件已经存在"
fi

bash "${path_script}/Config/${file_name}/${print_array[pick]}.sh" "$path"

chmod +x "${path}/${print_array[pick]}.sh"
declare cron_job="${cron} ${path}/${print_array[pick]}.sh"
(crontab -l 2>/dev/null | grep -v "${print_array[pick]}.sh") | sudo crontab -
(crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab -

sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"

echo "配置完成"