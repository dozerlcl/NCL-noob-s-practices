; 按一定规律命名的NC数据的批量读入
; 处理时次写在文件名中的情况
begin
  dir_sim = "./practice/lx9_data/" ;文件路径
;;systemfunc读入所有文件
  nc_files = systemfunc("ls "+dir_sim+"*.nc"); 批量读入文件systemfunc('ls'+"文件名共同部分.*.nc")
  f = addfiles(nc_files,"r")
  ListSetType(f,"join"); 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
  file_num = ListCount(f)
;;从文件名中截取出时次信息file_time
  file_names = new(file_num, string) ; 文件名字符串数组
  file_time  = new(file_num, string) ; 时次，后面转化为int64
  do i = 0, file_num - 1
    file_names(i) = getfilepath(f[i])
  end do
  ; print(file_names)
  ;;>>>re:查找子字符串各字符索引,很原始的方法,以后换文件名，修改这里，并且
  keywords_loc1 = indStrSubset(file_names(0), "20140528.") ; 位置 23-31
    print(keywords_loc1)
  keywords_loc2 = indStrSubset(file_names(0), ".170000") ; 位置 31-37 
     print(keywords_loc2)
  ;;字符串的删改，并且转换为整数，提取(23-30)+(32-37) , 上面例子中截取 2014052817 返回值为YYYYMMDDHH的形式
  do i = 0, file_num - 1
    ; ListAppend(file_names, getfilepath(f[i]))
    file_time(i) = str_get_cols(file_names(i), 23, 30) + str_get_cols(file_names(i), 32, 33) 
  end do
  file_time = totype(file_time, "int64") ; 用长整型保存
;;将file_time转换成时间维度，并且贴合进变量attributes
  ;先读入变量
  O3=f[:]->$"IJ-AVG-S__O3"$;将臭氧8小时平均中的臭氧值赋值
  O3!0 = "time"
  O3&time = file_time
  O3!1 = "lat" ; 稍微改一下名称
  O3!2 = "lon" ; 同上
  printVarSummary(O3)
end