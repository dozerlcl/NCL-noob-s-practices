; convert YYYYMMDD date to time values
; 将文件句柄中的文件名导出成时间信息，并按照信息索引数组进行处理;(自用)
begin
  dir_sim = "./practice/lx9_data/" ;文件路径
;;systemfunc读入所有文件
  nc_files = systemfunc("ls "+dir_sim+"*.nc"); 批量读入文件systemfunc('ls'+"文件名共同部分.*.nc")
  f = addfiles(nc_files,"r")
  ListSetType(f,"join"); 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
  file_num = ListCount(f)
  times_num = 4 ; 四个时间信息
;;从文件名中截取出时次信息file_time
  file_names = new(file_num, "string") ; 文件名字符串数组
  file_times = new((/4, file_num/), "string") ; 时次，后面转化为integer
  do i = 0, file_num - 1
    file_names(i) = getfilepath(f[i])
  end do
  ;;>>>re:查找子字符串各字符索引,很原始的方法,以后换文件名，修改这里，并且
  keywords_loc1 = indStrSubset(file_names(0), "20140528.") ; 位置 23-31
  ; year 23 - 26 ; month 27 - 28 ; day 29 30
  keywords_loc2 = indStrSubset(file_names(0), ".170000") ; 位置 31-37 
  ; hour 32 - 33
  ;;字符串的删改，并且转换为整数，提取(23-30)+(32-37) , 上面例子中截取 2014052817 返回值为YYYYMMDDHH的形式
  do i = 0, file_num - 1
    ; ListAppend(file_names, getfilepath(f[i]))
    file_times(0,i) = str_get_cols(file_names(i), 23, 26) ;提取yyyy
    file_times(1,i) = str_get_cols(file_names(i), 27, 28) ;提取mm
    file_times(2,i) = str_get_cols(file_names(i), 29, 30) ;提取dd 
    file_times(3,i) = str_get_cols(file_names(i), 32, 33) ;提取hh
  end do
  file_times = totype(file_times, "integer") ; 用长整型保存
  time_dims = dimsizes(file_times)
;;将file_time转换成时间维度，并且贴合进变量attributes
  ;先读入变量
  O3=f[:]->$"IJ-AVG-S__O3"$    ;将臭氧8小时平均中的臭氧值赋值
  O3!0 = "time_rec"            ; 时间序列号
  O3!1 = "lat"                 ; 稍微改一下名称
  O3!2 = "lon"                 ; 同上
  printVarSummary(O3) ; 把join的属性改成 time_rec
;;>>>示例使用ind+条件+rec号方式，进行一定时次的文件的框选处理：计算29日的滑动平均
  inx_dd29 = ind(file_times(2,:) .eq. 29 .and. file_times(1,:).eq.5) 
  \; 查找mm=5&&dd = 29的时间位置，当心算进去别的年份和月份的29日的值
  eight_runave_dd29 = runave_n_Wrap(O3(inx_dd29,:,:), 8, 0, 0) ; 将29日的17个时次的文件算八小时的滑动平均
  max_dd29 = dim_max_n(eight_runave_dd29, 0); 

end