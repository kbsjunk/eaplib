@msExportFolderCode = "$USRAREA"  // server folder code where the files will be dumped to

//===============================================================================================//

Option Strict On
Option Explicit On

References System
References System.Data

@moProcessesWithErrors = String.Empty
@moFilesGenerated = String.Empty

// Constants used in the filenames
@app_doc_req = "app_doc_req"
@app_req = "app_req"
@app_req_crt = "app_req_crt"
@app_req_std_cd = "app_req_std_cd"
@cnf_em = "cnf_em"
@cnf_em_crt = "cnf_em_crt"
@doc_req = "doc_req"
@inst_app_req = "inst_app_req"
@inst_cnf_em = "inst_cnf_em"
@spk_app_req = "spk_app_req"
@spk_cat = "spk_cat"
@spk_cat_app_req = "spk_cat_app_req"
@spk_cat_cnf_em = "spk_cat_cnf_em"
@spk_cd = "spk_cd"
@spk_cnf_em = "spk_cnf_em"
@spk_ver = "spk_ver"
@std_cd = "std_cd"
@std_cd_val = "std_cd_val"
@sub_req_crt = "sub_req_crt"
@usr_fld = "usr_fld"

@msDatabaseId = String.Empty 

Run_Export()

Function Run_Export As Boolean
  
  StatLog.Write("eApplication Library Export started." & vbCrLf)
  
  Dim loSW As System.IO.StreamWriter
  Dim lsFolderPath As String = T1.Tb.IO.DirectoryCode.GetAbsolutePath(@msExportFolderCode)
  Dim lsFilename As String = String.Empty
  
  // Construct the filename
  @msDatabaseId = msGetDatabaseId()
  
  lsFilename = "eaplib_" & @msDatabaseId & "_" & Format(Now, "yyyyMMddHHmmss") & ".xml"
  
  Try
  loSW = New System.IO.StreamWriter(lsFolderPath &  lsFilename) //& "\eaplib\" ??
  Catch ex As Exception
  StatLog.Write(ex.Message)  // remember: if exceptions aren't caught, they terminate the script at that point, which we don't want
  Return False
  End Try
  
  loSW.WriteLine("<?xml version=""1.0""?>")
  
loSW.WriteLine("<export>")
loSW.WriteLine("  <exportSource>")
loSW.WriteLine("    <date>" & Format(Now, "yyyy-MM-dd HH:mm:ss") & "</date>")
loSW.WriteLine("    <environment>" & @msDatabaseId & "</environment>")
loSW.WriteLine("  </exportSource>")
  
loSW.WriteLine("  <exportTables>")

  // Perform each export process
DoProcess(@app_doc_req, loSW)
DoProcess(@app_req, loSW)
DoProcess(@app_req_crt, loSW)
DoProcess(@app_req_std_cd, loSW)
DoProcess(@cnf_em, loSW)
DoProcess(@cnf_em_crt, loSW)
DoProcess(@doc_req, loSW)
DoProcess(@inst_app_req, loSW)
DoProcess(@inst_cnf_em, loSW)
DoProcess(@spk_app_req, loSW)
DoProcess(@spk_cat, loSW)
DoProcess(@spk_cat_app_req, loSW)
DoProcess(@spk_cat_cnf_em, loSW)
DoProcess(@spk_cd, loSW)
DoProcess(@spk_cnf_em, loSW)
DoProcess(@spk_ver, loSW)
DoProcess(@std_cd, loSW)
DoProcess(@std_cd_val, loSW)
DoProcess(@sub_req_crt, loSW)
DoProcess(@usr_fld, loSW)

  loSW.WriteLine("  </exportTables>")
  loSW.WriteLine("</export>")
  
  StatLog.Write("The following tables have been exported to the export file : " & vbCrLf & @moFilesGenerated)
  
  loSW.Close()
  
  Results.ReturnValue = True
  
End Function


// Performs each process by calling the appropriate process function
Private Sub DoProcess(ByVal processName As String, ByRef loSW As System.IO.StreamWriter)
  Dim lbResult As Boolean = False
  Dim loDS As System.Data.DataSet
  
  Try
  StatLog.Write("Preparing export of " & processName & " ....")
  Select Case processName 
  Case @app_doc_req
    loDS = DoSQL_app_doc_req(processName)
  Case @app_req
    loDS = DoSQL_app_req(processName)
  Case @app_req_crt
    loDS = DoSQL_app_req_crt(processName)
  Case @app_req_std_cd
    loDS = DoSQL_app_req_std_cd(processName)
  Case @cnf_em
    loDS = DoSQL_cnf_em(processName)
  Case @cnf_em_crt
    loDS = DoSQL_cnf_em_crt(processName)
  Case @doc_req
    loDS = DoSQL_doc_req(processName)
  Case @inst_app_req
    loDS = DoSQL_inst_app_req(processName)
  Case @inst_cnf_em
    loDS = DoSQL_inst_cnf_em(processName)
  Case @spk_app_req
    loDS = DoSQL_spk_app_req(processName)
  Case @spk_cat
    loDS = DoSQL_spk_cat(processName)
  Case @spk_cat_app_req
    loDS = DoSQL_spk_cat_app_req(processName)
  Case @spk_cat_cnf_em
    loDS = DoSQL_spk_cat_cnf_em(processName)
  Case @spk_cd
    loDS = DoSQL_spk_cd(processName)
  Case @spk_cnf_em
    loDS = DoSQL_spk_cnf_em(processName)
  Case @spk_ver
    loDS = DoSQL_spk_ver(processName)
  Case @std_cd
    loDS = DoSQL_std_cd(processName)
  Case @std_cd_val
    loDS = DoSQL_std_cd_val(processName)
  Case @sub_req_crt
    loDS = DoSQL_sub_req_crt(processName)
  Case @usr_fld
    loDS = DoSQL_usr_fld(processName)
  Case Else
    @moProcessesWithErrors = @moProcessesWithErrors & processName & vbCrLf
    StatLog.Write("Export of " & processName & " **FAILED**. Query does not exist.")
    Exit Sub
  End Select
  
  Catch ex As Exception
  StatLog.Write("Error detected in DoSQL of " & processName & " : " & ex.Message)
  End Try
  
  lbResult = WriteToFile(loDS, processName, loSW)
  
  If Not lbResult Then
    @moProcessesWithErrors = @moProcessesWithErrors & processName & vbCrLf
    StatLog.Write("Export of " & processName & " **FAILED** with errors.")
  Else
    StatLog.Write("Export of " & processName & " SUCCEEDED.")
  End If
  
  
  
End Sub

//===========================================================================//
//   Data Extraction Methods
//===========================================================================//


// File: Application Requirement Document Requirements (app_doc_req)
Private Function DoSQL_app_doc_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  app_rqmnt_cd, 
  doc_rqmnt_cd, 
  online_submit_fg, 
  physical_submit_fg 
FROM 
  s1eap_app_rqmnt_doc_rqmnts
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Application Requirements (app_req)
Private Function DoSQL_app_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  app_rqmnt_cd, 
  app_rqmnt_descr, 
  app_rqmnt_full_descr, 
  active_fg, 
  doc_rqmnt_comp_fg, 
  resp_prompt_fg, 
  max_number_responses, 
  default_number_responses, 
  required_number_responses, 
  parent_app_rqmnt_cd, 
  app_subreq_crit_grp_id AS sub_req_crt_grp 
FROM 
  s1eap_app_rqmnt_det
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Application Requirement Display Criteria (app_req_crt)
Private Function DoSQL_app_req_crt(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  crt.app_rqmnt_cd, 
  crt.crit_type, 
  stct.code_descr AS crit_name, 
  crt.crit_op, 
  crto.code_descr AS crit_descr, 
  itm.crit_value_alpha AS crit_code, 
  stc.code_descr AS crit_value 
FROM 
  s1eap_app_rqmnt_crit_det crt 
  INNER JOIN s1eap_crit_items itm ON (
    crt.app_rqmnt_cd = itm.entity_id 
    AND crt.crit_type = itm.crit_type 
    AND itm.entity_type = 'APPREQ'
  ) 
  LEFT JOIN s1stc_code stc ON (
    itm.crit_type = stc.code_type 
    AND itm.crit_value_alpha = stc.code_id
  ) 
  LEFT JOIN s1stc_code stct ON (
    itm.crit_type = stct.code_id 
    AND stct.code_type = 'S1_EAP_CRIT_TYPE'
  ) 
  LEFT JOIN s1stc_code crto ON (
    crt.crit_op = crto.code_id 
    AND crto.code_type = 'S1_EAP_CRIT_OP'
  ) 
WHERE 
  crt.crit_type <> 'CITIZENSHIP' 
UNION 
SELECT 
  DISTINCT crt.app_rqmnt_cd, 
  crt.crit_type, 
  'Student''s Citizenship', 
  'INCL' AS crit_op, 
  'One Of' AS crit_descr, 
  CASE WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'INT' WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'DOM' ELSE NULL END AS crit_code, 
  CASE WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'International' WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'Domestic' ELSE NULL END AS crit_value 
FROM 
  s1eap_app_rqmnt_crit_det crt 
  INNER JOIN s1eap_crit_items itm ON (
    crt.app_rqmnt_cd = itm.entity_id 
    AND crt.crit_type = itm.crit_type 
    AND itm.entity_type = 'APPREQ'
  ) 
  LEFT JOIN s1stc_code stc ON (
    itm.crit_type = stc.code_type 
    AND itm.crit_value_alpha = stc.code_id
  ) 
WHERE 
  crt.crit_type = 'CITIZENSHIP'
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Application Requirement Standard Codes (app_req_std_cd)
Private Function DoSQL_app_req_std_cd(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  DISTINCT key1 AS app_rqmnt_cd, 
  code_type 
FROM 
  s1usr_response_field 
WHERE 
  response_field_entity_type = 'APP_REQ' 
  AND code_type <> ' '
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: eApplication Submission Texts (cnf_em)
Private Function DoSQL_cnf_em(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  eap_rspns_cd, 
  eap_rspns_descr, 
  eap_rspns_text 
FROM 
  s1eap_rspns_det
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: eApplication Submission Text Criteria (cnf_em_crt)
Private Function DoSQL_cnf_em_crt(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  crt.eap_rspns_cd, 
  crt.crit_type, 
  stct.code_descr AS crit_name, 
  crt.crit_op, 
  crto.code_descr AS crit_descr, 
  itm.crit_value_alpha AS crit_code, 
  stc.code_descr AS crit_value 
FROM 
  s1eap_rspns_crit_det crt 
  INNER JOIN s1eap_crit_items itm ON (
    crt.eap_rspns_cd = itm.entity_id 
    AND crt.crit_type = itm.crit_type 
    AND itm.entity_type = 'EAPRSPNS'
  ) 
  LEFT JOIN s1stc_code stc ON (
    itm.crit_type = stc.code_type 
    AND itm.crit_value_alpha = stc.code_id
  ) 
  LEFT JOIN s1stc_code stct ON (
    itm.crit_type = stct.code_id 
    AND stct.code_type = 'S1_EAP_CRIT_TYPE'
  ) 
  LEFT JOIN s1stc_code crto ON (
    crt.crit_op = crto.code_id 
    AND crto.code_type = 'S1_EAP_CRIT_OP'
  ) 
WHERE 
  crt.crit_type <> 'CITIZENSHIP' 
UNION 
SELECT 
  DISTINCT crt.eap_rspns_cd, 
  crt.crit_type, 
  'Student''s Citizenship', 
  'INCL' AS crit_op, 
  'One Of' AS crit_descr, 
  CASE WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'INT' WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'DOM' ELSE NULL END AS crit_code, 
  CASE WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'International' WHEN crt.crit_type = 'CITIZENSHIP' 
  AND (
    (
      crt.crit_op = 'EXCL' 
      AND stc.trln_code_id = 'Y'
    ) 
    OR (
      crt.crit_op = 'INCL' 
      AND stc.trln_code_id = 'N'
    )
  ) THEN 'Domestic' ELSE NULL END AS crit_value 
FROM 
  s1eap_rspns_crit_det crt 
  INNER JOIN s1eap_crit_items itm ON (
    crt.eap_rspns_cd = itm.entity_id 
    AND crt.crit_type = itm.crit_type 
    AND itm.entity_type = 'EAPRSPNS'
  ) 
  LEFT JOIN s1stc_code stc ON (
    itm.crit_type = stc.code_type 
    AND itm.crit_value_alpha = stc.code_id
  ) 
WHERE 
  crt.crit_type = 'CITIZENSHIP'
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Document Requirements (doc_req)
Private Function DoSQL_doc_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  doc_rqmnt_cd, 
  doc_rqmnt_descr, 
  doc_rqmnt_full_descr, 
  stu_doc_type_cd, 
  doc_no_prompt_fg, 
  doc_no_prompt_descr, 
  issue_dt_prompt_fg, 
  issue_dt_prompt_descr, 
  expy_dt_prompt_fg, 
  expy_dt_prompt_descr, 
  active_fg, 
  add_info_link_src_cd, 
  add_info_link_name, 
  add_info_url_txt, 
  add_info_dir_code_type, 
  add_info_dir_code, 
  add_info_file_name, 
  add_info_link_lbl_disp_fg, 
  add_info_link_lbl_txt 
FROM 
  s1eap_doc_rqmnt_det
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Institution Application Requirements (inst_app_req)
Private Function DoSQL_inst_app_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  app_rqmnt_cd, 
  seq_no, 
  active_fg 
FROM 
  s1eap_inst_app_rqmnts
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Institution eApplication Submission Texts (inst_cnf_em)
Private Function DoSQL_inst_cnf_em(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  eap_rspns_cd, 
  eap_rspns_cd AS seq_no, 
  active_fg 
FROM 
  s1eap_inst_rspns
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package Application Requirements (spk_app_req)
Private Function DoSQL_spk_app_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  spk_cd, 
  spk_ver_no, 
  spk_cd || '/' || spk_ver_no AS spk_id, 
  app_rqmnt_cd, 
  seq_no, 
  active_fg 
FROM 
  s1eap_spk_app_rqmnts 
  INNER JOIN s1spk_det USING (spk_no, spk_ver_no)
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package Category Types (spk_cat)
Private Function DoSQL_spk_cat(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  spk_cat_type_cd, 
  spk_cat_type_desc, 
  spk_cat_lvl_cd, 
  study_type_cd, 
  allow_online_app_fg AS self_apply_fg 
FROM 
  s1cat_type 
WHERE 
  spk_cat_cd = 'CO'
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package Category Type Application Requirements (spk_cat_app_req)
Private Function DoSQL_spk_cat_app_req(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  app_rqmnt_cd, 
  spk_cat_type_cd, 
  seq_no, 
  active_fg 
FROM 
  s1eap_spk_cat_type_app_rqmnts
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package Category Type eApplication Submission Texts (spk_cat_cnf_em)
Private Function DoSQL_spk_cat_cnf_em(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  eap_rspns_cd, 
  spk_cat_type_cd, 
  eap_rspns_cd AS seq_no, 
  active_fg 
FROM 
  s1eap_spkcattype_rspns 
WHERE 
  eap_rspns_cd <> ' '
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Packages (spk_cd)
Private Function DoSQL_spk_cd(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  DISTINCT spk.spk_no, 
  spk.spk_cd, 
  spk.spk_cat_type_cd, 
  spk.spk_full_title, 
  CASE WHEN crsa.spk_no IS NULL THEN 'N' ELSE 'Y' END AS self_apply_fg 
FROM 
  s1spk_det spk 
  LEFT JOIN s1spk_crse_availabilities crsa ON (
    spk.spk_no = crsa.spk_no 
    AND spk.spk_ver_no = crsa.spk_ver_no
  ) 
WHERE 
  spk.spk_cat_cd = 'CO' 
  AND (
    spk.spk_no IN (
      SELECT 
        spk_no 
      FROM 
        s1eap_spk_app_rqmnts
    ) 
    OR spk.spk_cat_cd IN (
      SELECT 
        spk.spk_cat_cd 
      FROM 
        s1eap_spk_cat_type_app_rqmnts
    )
  )
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package eApplication Submission Texts (spk_cnf_em)
Private Function DoSQL_spk_cnf_em(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  spk_cd, 
  spk_ver_no, 
  spk_cd || '/' || spk_ver_no AS spk_id, 
  eap_rspns_cd, 
  eap_rspns_cd AS seq_no, 
  active_fg 
FROM 
  s1eap_spk_rspns 
  INNER JOIN s1spk_det USING (spk_no, spk_ver_no) 
WHERE 
  eap_rspns_cd <> ' '
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Study Package Versions (spk_ver)
Private Function DoSQL_spk_ver(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  DISTINCT spk.spk_no, 
  spk.spk_cd, 
  spk.spk_ver_no, 
  spk.spk_cd || '/' || spk.spk_ver_no AS spk_id, 
  spk.spk_cat_type_cd, 
  spk.spk_stage_cd, 
  spk.spk_full_title, 
  CASE WHEN crsa.spk_no IS NULL THEN 'N' ELSE 'Y' END AS self_apply_fg 
FROM 
  s1spk_det spk 
  LEFT JOIN s1spk_crse_availabilities crsa ON (
    spk.spk_no = crsa.spk_no 
    AND spk.spk_ver_no = crsa.spk_ver_no
  ) 
WHERE 
  spk.spk_cat_cd = 'CO' 
  AND (
    spk.spk_no IN (
      SELECT 
        spk_no 
      FROM 
        s1eap_spk_app_rqmnts
    ) 
    OR spk.spk_cat_cd IN (
      SELECT 
        spk.spk_cat_cd 
      FROM 
        s1eap_spk_cat_type_app_rqmnts
    )
  )
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Standard Codes (std_cd)
Private Function DoSQL_std_cd(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  code_type, 
  code_type_descr, 
  maint_by_code 
FROM 
  s1stc_code_type 
WHERE 
  code_type IN (
    SELECT 
      distinct CODE_TYPE 
    FROM 
      s1usr_response_field 
    WHERE 
      response_field_entity_type = 'APP_REQ'
  )
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Standard Code Values (std_cd_val)
Private Function DoSQL_std_cd_val(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  code_type, 
  code_id, 
  code_descr, 
  active_flag as active_fg, 
  seq_no, 
  maint_by_code 
FROM 
  s1stc_code 
WHERE 
  code_type IN (
    SELECT 
      distinct CODE_TYPE 
    FROM 
      s1usr_response_field 
    WHERE 
      response_field_entity_type = 'APP_REQ'
  )
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Application Subrequirement Criteria (sub_req_crt)
Private Function DoSQL_sub_req_crt(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  app_subreq_crit_id, 
  app_rqmnt_cd, 
  app_subreq_crit_grp_id AS sub_req_crt_grp, 
  response_field_id, 
  crit_op, 
  crit_value 
FROM 
  s1eap_app_subreq_crit
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


// File: Application Requirement Response Fields (usr_fld)
Private Function DoSQL_usr_fld(ByVal processName As String) As System.Data.DataSet
  Dim loDS As System.Data.DataSet 
  
ExecSQL.Begin
SELECT 
  key1 AS app_rqmnt_cd, 
  label, 
  data_type, 
  watermark, 
  hint_text, 
  skin_id, 
  code_type, 
  maximum_length, 
  mandatory_fg, 
  seq_no, 
  response_field_id 
FROM 
  s1usr_response_field 
WHERE 
  response_field_entity_type = 'APP_REQ' 
  AND deleted_fg = 'N'
ExecSQL.End
  
  loDS = ExecSQL.ExecuteDataSet()
  
  Return loDS
End Function

//---------------------------------------------------------------------------//


//===========================================================================//
//   Supporting Methods
//===========================================================================//

// Writes data out to a file
Private Function WriteToFile(ByVal dataSet As System.Data.DataSet, ByVal processName As String, ByRef loSW As System.IO.StreamWriter) As Boolean
  
  Dim liColumnCount As Integer 
  
  If dataSet.Tables.Count = 0 Then 
    StatLog.Write("An error occurred when executing to the dataset in " & processName & ". Check the final SQL select statement.")
    Return False
  End If
  
  liColumnCount = dataSet.Tables(0).Columns.Count
  
  loSW.WriteLine("      <exportTable>")
  loSW.WriteLine("        <tableName>" & processName & "</tableName>")
  
  loSW.WriteLine("        <tableData>")
  loSW.WriteLine("<![CDATA[")
  
  Dim j as Integer = 0
  Dim lsValue as String
  
  For Each loColumn as System.Data.DataColumn in dataSet.Tables(0).Columns
    loSW.Write("""" & LCase(loColumn.ColumnName) & """")
    If j < (liColumnCount - 1) Then loSW.Write(",")  // append a delimiter if this isn't the last field on the line
    j = j + 1
  Next
  
  loSW.Write(vbCrLf)
  
  For Each loRow As System.Data.DataRow In dataSet.Tables(0).Rows
    For i As Integer = 0 To liColumnCount - 1
      If TypeOf loRow.Item(i) Is Date Then
        loSW.Write(Format(loRow.Item(i), "dd-MMM-yyyy"))  // e.g. 28-Apr-2008
      Else
        
        lsValue = loRow.Item(i).ToString
        lsValue = Replace(lsValue, """", """""")
        lsValue = Replace(lsValue, vbCrLf, ";;")
        lsValue = Replace(lsValue, vbCr, ";;")
        lsValue = Replace(lsValue, vbLf, ";;")
        
        loSW.Write("""" & lsValue & """")
      End If
      If i < (liColumnCount - 1) Then loSW.Write(",")  // append a delimiter if this isn't the last field on the line
    Next
    loSW.Write(vbCrLf)
  Next
  
  loSW.WriteLine("]]>")
  loSW.WriteLine("        </tableData>")
  
  loSW.WriteLine("      </exportTable>") 
  
  @moFilesGenerated = @moFilesGenerated & " " & processName & vbCrLf
  
  Return True
End Function

Private Function msGetDatabaseId() As String
  ExecSQL.Begin
  select value
  from   f1_sypar_ctl
  where  param_name = 'UM_DATABASE_ID'
  ExecSQL.End
  If ExecSQL.IsError Then Return String.Empty
  
  Return ExecSQL.Value("value", 1)
End Function