;����BC���ǰ�Ĵ�������
;��������R �� TXT ����� �����ú��ʵ� ԭʼ���� �����Դ���֮
;��Լ��ͼʱ�� ���reshape bc�����bc_r��
;3.16�޸�ΪRegCM��bcǰ����
;3.31�������� RMSE ʹ�ú������㣬ʱ���ϵ�RMSE
begin
;>>>-------------------------------------------------read CN05.1 data
;  �ļ�·������
modname1 = "regcm"
; modname2 = "CCLM"  ; �ļ����в����ִ�Сд,����
; 
  f_tm_cat = addfile("~/practice/bc_data/temporary_data/bc_tm/ncl_to_r/tm_cat_CN051_"+modname1+"_step2"+".nc", "r")

    ; list_filevars(f_CN051_TM) 
    tm_cn051_cat = f_tm_cat->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(tm_CN051&time) ; ���ñ�����time���� 19890101-20091231 ��������
    tm_CN051_time = cd_calendar(tm_cn051_cat&time, 2)
    it_s=20000101  ;��ʼ���� 1998(3287)
    it_e=20011231  ;��������
    rec_s = ind(it_s .eq. tm_CN051_time)      ;��ȡ��ʼʱ��ļ�¼�� 4017(2000)
    rec_e = ind(it_e .eq. tm_CN051_time)      ;��ȡ����ʱ��ļ�¼�� 4747(2001)
    tm_cn051_needed = tm_cn051_cat(time|rec_s:rec_e,lat|:,lon|:)
    ; dim_needed = dimsizes(tm_cn051_cat)
    ; printVarSummary(dim_needed)
    ; printVarSummary(tm_cn051_needed)
;>>>--------------------------------------------------bc��txt�ļ���R���
;#########################################################################################
  ; bc_path = "./practice/bc_data/temporary_data/bc_tm/bc_step2_test.txt"
  bc_path = "~/practice/bc_data/temporary_data/bc_tm/r_to_ncl/bc_step2_test_"+modname1+".txt"
;#########################################################################################
  bc_tm = asciiread(bc_path, (/731 ,163 , 283/), "float") ; ע��R�Ĵ������������ݣ�������仯˳���R���෴��
  bc_tm!0 = "time"
  bc_tm&time = tm_cn051_needed&time
  bc_tm!2 = "lon"
  bc_tm&lon = tm_cn051_needed&lon
  bc_tm!1 = "lat"
  bc_tm&lat = tm_cn051_needed&lat
  bc_tm_r = bc_tm(time|:,lat|:,lon|:)
  copy_VarAtts(tm_cn051_needed, bc_tm_r)
  bc_tm_r@_FillValue = -9999.

;>>>-------------------------------------------------����BC��cor,prob,minusͼ
  ; cor_tm_bc = escorc_n(bc_tm_r, tm_cn051_needed, 0, 0)
  ; prob_tm_bc = rtest(cor_tm_bc, 4747-4017, 0)
  minus = bc_tm_r - tm_cn051_needed
  minus = abs(minus)
  minus_ave = dim_avg_n(minus, 0)
  rmse = dim_rmsd_n(bc_tm_r, tm_cn051_needed, 0) ; ʱ������rmse���ÿռ�ͼ  
  copy_VarMeta(tm_cn051_needed(0,:,:),minus_ave)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),cor_tm_bc)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),prob_tm_bc)
  copy_VarMeta(tm_cn051_needed(0,:,:),rmse)
  printVarSummary(rmse)
  printMinMax(rmse, 1)
;>>>---------------------------------------------------���ȱʧֵ
  ; check_bc = num(ismissing(bc_tm_r))
  ; check_cn051  = num(ismissing(tm_cn051_needed))
  ; print("------------------------------check ismissing--------------------------------")
  ; print(check_bc)
  ; print(check_cn051)
  ; print("------------------------------check ismissing--------------------------------")
;>>>---------------------------------------------------������ļ���
  path_out = "~/practice/bc_data/temporary_data/bc_tm/bc_tm_"+modname1+"_02"+".nc" ; �޸�·����_02
  system("rm -f "+path_out) ;ɾ��Ŀ¼�µ�ͬ���ļ�
  ncdf = addfile(path_out, "c") ; c��ʾ����netcdf�ļ�
  ; ncdf->cor_tm_bc = cor_tm_bc ;д�������ֵ
  ; ncdf->prob_tm_bc = prob_tm_bc
  ncdf->minus_tm_bc = minus_ave
  ncdf->rmse = rmse
  delete(ncdf)

end