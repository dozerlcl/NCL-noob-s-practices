;绘制BC结果前的处理程序
;整理来自R 的 TXT 结果， 并且用合适的 原始数据 的属性代替之
;节约绘图时间 最后将reshape bc输出（bc_r）
;3.16修改为RegCM的bc前处理
;3.31增加数据 RMSE 使用函数计算，时间上的RMSE
begin
;>>>-------------------------------------------------read CN05.1 data
;  文件路径参数
modname1 = "regcm"
; modname2 = "CCLM"  ; 文件名中不区分大小写,弃用
; 
  f_tm_cat = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_"+modname1+"_step2"+".nc", "r")

    ; list_filevars(f_CN051_TM) 
    tm_cn051_cat = f_tm_cat->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(tm_CN051&time) ; 调用变量的time坐标 19890101-20091231 逐日数据
    tm_CN051_time = cd_calendar(tm_cn051_cat&time, 2)
    it_s=20000101  ;起始年月 1998(3287)
    it_e=20011231  ;结束年月
    rec_s = ind(it_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017(2000)
    rec_e = ind(it_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747(2001)
    tm_cn051_needed = tm_cn051_cat(time|rec_s:rec_e,lat|:,lon|:)
    ; dim_needed = dimsizes(tm_cn051_cat)
    ; printVarSummary(dim_needed)
    ; printVarSummary(tm_cn051_needed)
;>>>--------------------------------------------------bc的txt文件，R结果
;#########################################################################################
  ; bc_path = "./practice/bc_data/temporary_data/bc_tm/bc_step2_test.txt"
  bc_path = "~/practice/bc_data/temporary_data/bc_tm/r_to_ncl/bc_step2_test_"+modname1+".txt"
;#########################################################################################
  bc_tm = asciiread(bc_path, (/731 ,163 , 283/), "float") ; 注意R的处理出来的数据，是坐标变化顺序和R是相反的
  bc_tm!0 = "time"
  bc_tm&time = tm_cn051_needed&time
  bc_tm!2 = "lon"
  bc_tm&lon = tm_cn051_needed&lon
  bc_tm!1 = "lat"
  bc_tm&lat = tm_cn051_needed&lat
  bc_tm_r = bc_tm(time|:,lat|:,lon|:)
  copy_VarAtts(tm_cn051_needed, bc_tm_r)
  bc_tm_r@_FillValue = -9999.

;>>>-------------------------------------------------计算BC的cor,prob,minus图
  ; cor_tm_bc = escorc_n(bc_tm_r, tm_cn051_needed, 0, 0)
  ; prob_tm_bc = rtest(cor_tm_bc, 4747-4017, 0)
  minus = bc_tm_r - tm_cn051_needed
  minus = abs(minus)
  minus_ave = dim_avg_n(minus, 0)
  rmse = dim_rmsd_n(bc_tm_r, tm_cn051_needed, 0) ; 时间上做rmse，得空间图  
  copy_VarMeta(tm_cn051_needed(0,:,:),minus_ave)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),cor_tm_bc)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),prob_tm_bc)
  copy_VarMeta(tm_cn051_needed(0,:,:),rmse)
  printVarSummary(rmse)
  printMinMax(rmse, 1)
;>>>---------------------------------------------------检查缺失值
  ; check_bc = num(ismissing(bc_tm_r))
  ; check_cn051  = num(ismissing(tm_cn051_needed))
  ; print("------------------------------check ismissing--------------------------------")
  ; print(check_bc)
  ; print(check_cn051)
  ; print("------------------------------check ismissing--------------------------------")
;>>>---------------------------------------------------输出到文件中
  path_out = "~/practice/bc_data/temporary_data/bc_tm/bc_tm_"+modname1+"_02"+".nc" ; 修改路径到_02
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf = addfile(path_out, "c") ; c表示创建netcdf文件
  ; ncdf->cor_tm_bc = cor_tm_bc ;写入变量数值
  ; ncdf->prob_tm_bc = prob_tm_bc
  ncdf->minus_tm_bc = minus_ave
  ncdf->rmse = rmse
  delete(ncdf)

end