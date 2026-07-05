(defun c:CheckUpdateExtended ( / serverVersionUrl changelogUrl localVersionPath data content version lastDate today diff)
  (vl-load-com)
  
  ;; --- CẤU HÌNH ---
  (setq serverVersionUrl "https://raw.githubusercontent.com/billcase/HVAC23/refs/heads/main/version.txt")
  (setq changelogUrl "https://raw.githubusercontent.com/billcase/HVAC23/refs/heads/main/changelog.txt")
  (setq localVersionPath (strcat (getvar "ROAMABLEPREFIX") "c:\\HVAC23\\local_version.txt"))
  
  ;; Lấy ngày hiện tại (dạng YYYYMMDD)
  (setq today (atoi (menucmd "M=$(edtime,$(getvar,date),YYYYMMDD)")))
  
  ;; Đọc dữ liệu local
  (if (findfile localVersionPath)
    (progn
      (setq f (open localVersionPath "r"))
      (setq data (read-line f)) (close f)
      (setq version (substr data 1 (vl-string-search "|" data)))
      (setq lastDate (atoi (substr data (+ (vl-string-search "|" data) 2))))
    )
    (progn (setq version "1.0") (setq lastDate 0))
  )

  ;; Tính chênh lệch ngày (Đơn giản hóa: so sánh số nguyên ngày)
  (if (> (- today lastDate) 30) ; Nếu đã qua 30 ngày
    (progn
      (setq webObj (vlax-create-object "MSXML2.ServerXMLHTTP.6.0"))
      
      ;; Lấy version mới
      (vlax-invoke-method webObj 'open "GET" serverVersionUrl :vlax-false)
      (vlax-invoke-method webObj 'send)
      (if (= (vlax-get-property webObj 'status) 200)
        (progn
          (setq newVersion (vl-string-trim " \t\n\r" (vlax-get-property webObj 'responseText)))
          
          (if (/= version newVersion)
            (progn
              ;; Lấy nội dung Changelog
              (vlax-invoke-method webObj 'open "GET" changelogUrl :vlax-false)
              (vlax-invoke-method webObj 'send)
              (setq changelog (vlax-get-property webObj 'responseText))
              
              (alert (strcat "📢 CÓ BẢN CẬP NHẬT MỚI (" newVersion ")\n\n"
                             "Nội dung thay đổi:\n" changelog "\n\n"
                             "Vui lòng tải về tại https://bit.ly/hvaczwcad/."))
                             
              ;; Cập nhật ngày kiểm tra mới vào file local
              (setq f (open localVersionPath "w"))
              (write-line (strcat newVersion "|" (itoa today)) f)
              (close f)
            )
          )
        )
      )
      (vlax-release-object webObj)
    )
    (princ "\n[Update] Đã kiểm tra cập nhật gần đây. Hẹn quay lại sau.")
  )
  (princ)
)

(c:CheckUpdateExtended)