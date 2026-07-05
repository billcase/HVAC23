;;; ==========================================================
;;; LỆNH XDEL: XÓA ĐỐI TƯỢNG CON TRONG BLOCK KHÔNG CẦN BEDIT
;;; ==========================================================
(defun c:XDEL (/ ent)
  (vl-load-com)
  (while (setq ent (car (nentsel "\nChọn đối tượng trong Block để xóa (Nhấn Enter để thoát): ")))
    (if ent
      (progn
        (entdel ent)
        (command "_.REGEN")
        (princ "\nĐã xóa đối tượng và cập nhật Block.")
      )
    )
  )
  (princ)
)

;;; ==========================================================
;;; LỆNH XLAY: CHUYỂN ĐỐI TƯỢNG CON TRONG BLOCK SANG LAYER HIỆN HÀNH
;;; ==========================================================
(defun c:XLAY (/ ent edata clayer)
  (vl-load-com)
  (while (setq ent (car (nentsel "\nChọn đối tượng trong Block để chuyển Layer (Nhấn Enter để thoát): ")))
    (if ent
      (progn
        (setq edata (entget ent))
        (setq clayer (getvar "CLAYER"))
        
        ;; Cập nhật Layer
        (if (assoc 8 edata)
          (setq edata (subst (cons 8 clayer) (assoc 8 edata) edata))
          (setq edata (append edata (list (cons 8 clayer))))
        )
        
        ;; Đưa màu sắc (Color) về ByLayer để hiển thị đúng màu Layer mới (tùy chọn)
        (if (assoc 62 edata)
          (setq edata (subst (cons 62 256) (assoc 62 edata) edata)) ; 256 là mã ByLayer
        )

        (entmod edata)
        (entupd ent)
        (command "_.REGEN")
        (princ (strcat "\nĐã chuyển đối tượng sang Layer: " clayer))
      )
    )
  )
  (princ)
)