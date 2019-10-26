; 查找文件名形如YYYYMMDDHH格式的文件 中缺失的文件序号 
; 方法：从文件中提取出关键字段（参数需在timelocation中修改，会因file_path的改变而改变）
;       之后和从文件首尾（time_s,time_e，或者自己指定时间段，修改即可）生成逐小时标准时间序列
;     （也可通过YYYYMMDDHH_time函数修改），再在标准时间序列中查找缺失值
;注：首位出现缺失不能查找到
;    适用于批量读入一个文件夹中的所有文件，并且文件类型需要一致；
;还能补充：
;         用get_unique_values(x)列举所有年月日时次（不必要
;         将文件名而不是文件路径处理出来，用字符串删去文件路径或者找到能提取文件名的函数
begin
  dir_sim = "./practice/lx9_data/" ;文件路径
;;systemfunc读入所有文件
  nc_files = systemfunc("ls "+dir_sim+"*.nc") ; 批量读入文件systemfunc('ls'+"文件名共同部分.*.nc")
  f = addfiles(nc_files,"r")
  ListSetType(f,"join") ; 打开多个文件并且返回文件句柄（批量读入后实质上是一个list
  file_num = ListCount(f)
;;从文件名中截取出时次信息file_time
;;>>>参数修改
  times_num = 4 ; 四个时间信息,yy,mm,dd,hh
  time_location = (/(/23,26/),(/27,28/),(/29,30/),(/32,33/) /); 分别对应yyyy，mm，dd，hh的位置（含路径）
  file_names = new(file_num, "string") ; 含路径的文件名字符串数组
  file_times4check_s = new(file_num,"string") ; 文件名的字符串，形如YYYYMMDDHH
  file_times_s = new((/times_num, file_num/), "string")  ; 四个时间信息的字符串数组
  ; 时次，后面转化为integer,4表示四个时间维度，file_num即文件数目
  do i = 0, file_num - 1
    file_names(i) = getfilepath(f[i])
  end do
  time_s_s = str_get_cols(file_names(0), 23, 30) + str_get_cols(file_names(0), 32, 33)
  time_e_s = str_get_cols(file_names(file_num -1), 23, 30) + str_get_cols(file_names(file_num -1), 32, 33)
;;re:查找子字符串各字符索引，即time_location的位置,很原始的方法 
  ; keywords_loc1 = indStrSubset(file_names(0), "20140528.") ; 位置 23-31 year 23-26 month 27-28 day29-30
  ; keywords_loc2 = indStrSubset(file_names(0), ".170000") ; 位置 31-37 hour 32 - 33
;;字符串的删改，并且转换为整数，提取(23-30)+(32-37) , 上面例子中截取 2014052817 返回值为YYYYMMDDHH的形式
;;>>>设置完成
  time_locatin_dim = dimsizes(time_location)
  do i = 0, file_num - 1 ; 维度2存储逐个文件的时间
    do j = 0, time_locatin_dim(0) - 1 ; 维度1存储时间类型
      file_times_s(j,i) = str_get_cols(file_names(i), time_location(j,0), time_location(j,1)) ;提取
    end do
    file_times4check_s(i) = str_get_cols(file_names(i), 23, 30) + str_get_cols(file_names(i), 32, 33)
  end do
  file_times = totype(file_times_s, "integer") ; 用整型保存
  time_dims = dimsizes(file_times) ; 时次数量（times_num） x 文件数量（file_num）
  time_s = totype(time_s_s, "integer") ; 起始时间点
  time_e = totype(time_e_s, "integer") ; 结束时间点
  file_times4check = totype(file_times4check_s, "integer") ; 用于check的YYYYMMDDHH型的时间
  times_standarize_allyear = yyyymmddhh_time(file_times(0,0),file_times(0,file_num-1), 1, "integer") 
  ;先生成整年的时间序列
  times_standarize = times_standarize_allyear({time_s : time_e})
  ;使用引用提取出从 文件开始 到 文件结束 的时间序列
  wrongfile_check = new(dimsizes(times_standarize), "integer") ; 查找错误出现位置的数组
  wrongfile_switch = False ; 错误出现的快关
  do i=0, dimsizes(times_standarize) -1 ; 搜索缺失的文件按
      wrongfile_check(i) = get1Dindex(file_times4check, times_standarize(i)) 
      if ismissing(wrongfile_check(i)) then
        wrongfile_switch = True
      end if
  end do
  wrongfile_rec = ind(ismissing(wrongfile_check))
  ; print(wrongfile_switch)
  ; print(ismissing(wrongfile_rec))
  if wrongfile_switch then
    wrongfile_num = dimsizes(wrongfile_rec)
  else
    wrongfile_num = 0
  end if
  print("--------------------------------time check----------------------------------")
  print("文件中数据时次为： from "+time_s_s+" to " + time_e_s)
  print("下面检查文件时次的完整性:") 
  print("共 "+file_num+"个文件")
  if wrongfile_switch then
    print("其中"+wrongfile_num+"个时次出现问题")
    do i=0,wrongfile_num-1
      print("第 "+(i+1)+" 个缺失文件时次为： "+times_standarize(wrongfile_rec(i)))
    end do
  else 
    print("无缺失文件")
  end if
   print("-----------------------------check finished---------------------------------")
;;将file_time转换成时间维度，并且贴合进变量attributes
  ;先读入变量
  ; list_vars()
  O3=f[:]->$"IJ-AVG-S__O3"$    ;将臭氧8小时平均中的臭氧值赋值
  O3!0 = "time_rec"            ; 时间序列号
  O3!1 = "lat"                 ; 稍微改一下名称
  O3!2 = "lon"                 ; 同上
  ; printVarSummary(O3) ; 把join的属性改成 time_rec
;;>>>示例使用ind+条件+rec号方式，进行一定时次的文件的框选处理：计算29日的滑动平均
  inx_dd29 = ind(file_times(2,:) .eq. 29 .and. file_times(1,:).eq.5.and.file_times(0,:).eq.2014) 
  ; 查找mm=5&&dd = 29的时间位置，当心算进去别的年份和月份的29日的值
  eight_runave_dd29 = runave_n_Wrap(O3(inx_dd29,:,:), 8, 0, 0) ; 将29日的17个时次的文件算八小时的滑动平均
  max_dd29 = dim_max_n(eight_runave_dd29, 0); 
end