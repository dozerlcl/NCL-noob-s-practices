; 绘制BC结果和MOD结果与OBS相互比较的taylor图
; 前处理部分，先进行一些输出，stats统计函数的使用，之后再taylor中进行作图
; 3.16修改为RegCM的处理
; 3.26修改为处理出四季的脚本，先后处理了TM PRE
;   使用modname 控制路径的文件名；
;   在r_to_ncl 中，将BC附上属性输出为NC文件；

;**********************************
load "./offical_sample_script/download/taylor_diagram.ncl"
load "./offical_sample_script/download/taylor_stats.ncl"
load "./offical_sample_script/download/taylor_metrics_table.ncl"
;**********************************
begin
; 路径参数调整
modname = "wrf"
modname2 = "WRF"
type    = "tm"
;>>>-------------------------------------------------read CN05.1 data  

  f_tm_mod_cat = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_"+modname2+"_step2"+".nc", "r")
    ; list_filevars(f_CN051_TM) 
    ; _cat为保存的作图时段(2000-2001)变量后缀
    tm_cn051_cat = f_tm_mod_cat->$"tm_cn051_step2"$; 
    tm_wrf_cat = f_tm_mod_cat->$"tm_wrf_step2"$
    tm_CN051_time = cd_calendar(tm_cn051_cat&time, 2)
    it_s=20000101  ;起始年月 1998(3287)
    it_e=20011231  ;结束年月
    rec_s = ind(it_s .eq. tm_CN051_time)      ;获取开始时间的记录号 4017(2000)
    rec_e = ind(it_e .eq. tm_CN051_time)      ;获取结束时间的记录号 4747(2001)
    ; 截取夏季 和 冬季 的结果


;>>>--------------------------------------------------bc的txt文件，R结果

;###################################BC文件位置的参数设置####################################
  ; bc_path = "./practice/bc_data/temporary_data/bc_tm/bc_step2_test.txt"
  bc_path = "./practice/bc_data/temporary_data/bc_"+type+"/r_to_ncl/bc_"+type+"_"+modname+".nc"
;#########################################################################################

;bc_tm_r为改变维度后的bc结果
  ; bc_tm = asciiread(bc_path, (/731 ,163 , 283/), "float") 
  ; 注意R的处理出来的数据，是坐标变化顺序和R是相反的
  ; bc_tm!0 = "time"
  ; bc_tm&time = tm_cn051_cat&time
  ; bc_tm!2 = "lon"
  ; bc_tm&lon = tm_cn051_cat&lon
  ; bc_tm!1 = "lat"
  ; bc_tm&lat = tm_cn051_cat&lat
  ; bc_tm_r = bc_tm(time|:,lat|:,lon|:)
  ; copy_VarAtts(tm_cn051_cat, bc_tm_r)
  ; bc_tm_r@_FillValue = -9999.
  f_bc = addfile(bc_path, "r")
  bc_tm_r = f_bc->$"bc_tm"$
;>>>-------------------------------------------------拆分年份
  time_bc = cd_calendar(bc_tm_r&time, 0) ; time_bc为730 x 6 6个时间分别是yy mm dd hh mm ss
  ; 下面提取DJF
  ind_DJF = ind(time_bc(:,1).eq.1.or.time_bc(:,1).eq.2.or.time_bc(:,1).eq.12)
  bc_tm_DJF  = bc_tm_r(ind_DJF,:,:)
  ind_MAM = ind(time_bc(:,1).eq.3.or.time_bc(:,1).eq.4.or.time_bc(:,1).eq.5)
  bc_tm_MAM  = bc_tm_r(ind_MAM,:,:)
  ind_JJA = ind(time_bc(:,1).eq.6.or.time_bc(:,1).eq.7.or.time_bc(:,1).eq.8)
  bc_tm_JJA  = bc_tm_r(ind_JJA,:,:)
  ind_SON = ind(time_bc(:,1).eq.9.or.time_bc(:,1).eq.10.or.time_bc(:,1).eq.11)
  bc_tm_SON  = bc_tm_r(ind_SON,:,:)
;>>>-------------------------------------------------计算统计要素
  ; 观测值四季度平均
  tm_obs_ave_DJF = dim_avg_n(tm_cn051_cat(ind_DJF,:,:), 0)
  tm_obs_ave_MAM = dim_avg_n(tm_cn051_cat(ind_MAM,:,:), 0)
  tm_obs_ave_JJA = dim_avg_n(tm_cn051_cat(ind_JJA,:,:), 0)
  tm_obs_ave_SON = dim_avg_n(tm_cn051_cat(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_obs_ave_SON)
  ; 模式值四季度平均
  tm_mod_ave_DJF = dim_avg_n(tm_wrf_cat(ind_DJF,:,:), 0)
  tm_mod_ave_MAM = dim_avg_n(tm_wrf_cat(ind_MAM,:,:), 0)
  tm_mod_ave_JJA = dim_avg_n(tm_wrf_cat(ind_JJA,:,:), 0)
  tm_mod_ave_SON = dim_avg_n(tm_wrf_cat(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_SON)
  ; BC结果四季度平均
  tm_bc_ave_DJF = dim_avg_n(bc_tm_r(ind_DJF,:,:), 0)
  tm_bc_ave_MAM = dim_avg_n(bc_tm_r(ind_MAM,:,:), 0)
  tm_bc_ave_JJA = dim_avg_n(bc_tm_r(ind_JJA,:,:), 0)
  tm_bc_ave_SON = dim_avg_n(bc_tm_r(ind_SON,:,:), 0)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_DJF)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_MAM)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_JJA)
  copy_VarMeta(tm_cn051_cat(0,:,:), tm_mod_ave_SON)

;  function taylor_stats(t[*][*]:numeric, r[*][*]:numeric, w:numeric, opt[1]:integer)
  stats_mod_DJF = taylor_stats(tm_mod_ave_DJF,tm_obs_ave_DJF,1.0,1)
  stats_mod_MAM = taylor_stats(tm_mod_ave_MAM,tm_obs_ave_MAM,1.0,1)
  stats_mod_JJA = taylor_stats(tm_mod_ave_JJA,tm_obs_ave_JJA,1.0,1)
  stats_mod_SON = taylor_stats(tm_mod_ave_SON,tm_obs_ave_SON,1.0,1)

  stats_bc_DJF = taylor_stats(tm_bc_ave_DJF,tm_obs_ave_DJF,1.0,1)
  stats_bc_MAM = taylor_stats(tm_bc_ave_MAM,tm_obs_ave_MAM,1.0,1)
  stats_bc_JJA = taylor_stats(tm_bc_ave_JJA,tm_obs_ave_JJA,1.0,1)
  stats_bc_SON = taylor_stats(tm_bc_ave_SON,tm_obs_ave_SON,1.0,1)
  ; stats_res_mod1 = taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1)

;   stats_res_bc = taylor_stats(bc_tm_ave,tm_obs_ave,1.0,1)
;   stats_res_mod1 = taylor_stats(tm_mod1_ave,tm_obs_ave,1.0,1)
;   ; print(stats_res) ; 0-pattern_cor; 1-ratio; 2-bias (%); 3-tmean; 4-rmean; 5-tvar; 6-rvar; 7-rmse
;>>>--------------------------------------------------输出 stats结果
; 输出包含 stats_res_bc 作为mod1的统计分析结果 stats_res_mod1 作为mod的
  path_out = "./practice/bc_data/temporary_data/bc_"+type+"/taylor/taylor_seasons_"+modname+".nc"
  system("rm -f "+path_out) ;删除目录下的同名文件
  ncdf_out = addfile(path_out, "c") ; c表示创建netcdf文件
  ncdf_out->stats_bc_DJF = stats_bc_DJF
  ncdf_out->stats_bc_MAM = stats_bc_MAM
  ncdf_out->stats_bc_JJA = stats_bc_JJA 
  ncdf_out->stats_bc_SON = stats_bc_SON

  ncdf_out->stats_mod_DJF = stats_mod_DJF
  ncdf_out->stats_mod_MAM = stats_mod_MAM
  ncdf_out->stats_mod_JJA = stats_mod_JJA
  ncdf_out->stats_mod_SON = stats_mod_SON
  delete(ncdf_out)


end