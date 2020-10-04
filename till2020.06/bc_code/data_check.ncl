;  4.11 将bc_data转移到D卡中，注意修改bc_code中的路径
;    将绝对路径修改为windows路径，使用/mnt/
;    下面是一个示范，数据被存放在SD卡中
;    git中修改测试

begin
;>>>read CN05.1 data 
;"D:\DATAFILE\NCLDATA\precip.mon.mean.nc"
  windows_path = "/mnt/e/DATAFILE/NCLDATA/bc_data/RegCM_PRE_daily_025x025.nc"
  f_CN051_PRE = addfile(windows_path, "r")
  ; f_WRF_PRE   = addfile("~/practice/bc_data/RegCM_PRE_daily_025x025.nc","r")
  ; f_WRF_TM  = addfile("./practice/bc_data/CCLM_TMEAN_daily_025x025.nc","r")
  ;;;;;考虑读取两年的（20000101-20011231）记录号为（4017-4747）   数据过大不能一次性读入进变量
  ;>>>>05.1观测数据集,平均气温
    list_filevars(f_CN051_PRE)
    ; list_filevars(f_WRF_PRE) 
    ; pre_CN051_or = f_CN051_PRE->$"pre"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(pre_CN051_or)
end