;;;  DISK-PASTING  DISK-PASTING  DISK-PASTING  DISK-PASTING
;;;  DISK-PASTING  DISK-PASTING  DISK-PASTING  DISK-PASTING
;;;  DISK-PASTING  DISK-PASTING  DISK-PASTING  DISK-PASTING

(IN-PACKAGE "COMMON-LISP-USER")

(provide "disk-pasting")

(DEFUN DISK-PASTING-CMPR (cmpr new)
  (declare
    (type cmprf cmpr)
    (symbol new))
  (flet ((rslt (gnrt1 gnrt2)
	   (declare (type gnrt gnrt1 gnrt2))
	   (if (eq gnrt1 new)
	       (if (eq gnrt2 new)
		   :equal
		 :less)
	     (if (eq gnrt2 new)
		 :greater
	       (funcall cmpr gnrt1 gnrt2)))))
    (the cmprf #'rslt)))

#|
  (setf c (delta 3))
  (setf cmpr (disk-pasting-cmpr (cmpr c) 'new))
  (funcall cmpr 'new 'new)
  (funcall cmpr 'new 5)
  (funcall cmpr 5 'new)
  (funcall cmpr 5 5)
  (funcall cmpr 5 6)
  (funcall cmpr 6 5)
|#

(DEFUN DISK-PASTING-BASIS (basis dmns new)
  (declare
    (type basis basis)
    (fixnum dmns)
    (symbol new))
  (flet ((rslt (degr)
	   (declare (fixnum degr))
	   (if (= degr dmns)
	       (cons new (funcall basis dmns))
	     (funcall basis degr))))
    (the basis #'rslt)))

#|
  (setf c (delta 3))
  (setf basis (disk-pasting-basis (basis c) 3 'new))
  (funcall basis 3)
  (funcall basis 2)
|#

(DEFUN DISK-PASTING-INTR-DFFR (old-dffr degr new bndr)
  (declare
    (type morphism old-dffr)
    (fixnum degr)
    (symbol new)
    (type cmbn bndr))
  (when (cmbn-non-zero-p (cmbn-? old-dffr bndr))
    (error "In CHCM-DISK-PASTING, the given boundary has a non-null boundary."))
  (let ((cmpr (cmpr (trgt old-dffr))))
    (declare (type cmprf cmpr))
    (flet ((rslt (cmbn)
	     (declare (type cmbn cmbn))
	     (with-cmbn (degr2 list) cmbn
	       (unless (= degr degr2)
		 (return-from rslt
		   (cmbn-? old-dffr cmbn)))
	       (unless list
		 (return-from rslt
		   (zero-cmbn (1- degr))))
	       (unless (eq (-gnrt list) new)
		 (return-from rslt
		   (cmbn-? old-dffr cmbn)))
	       (2cmbn-add cmpr
		 (n-cmbn (-cffc list) bndr)
		 (cmbn-? old-dffr
			 (make-cmbn :degr degr
				    :list (rest list)))))))
      (the intr-mrph #'rslt))))

#|
  (cat-init)
  (setf c (delta 3))
  (setf intr (disk-pasting-intr-dffr (dffr c) 3 'new (cmbn 2 1 7)))
  (setf intr (disk-pasting-intr-dffr (dffr c) 3 'new (? c 3 15)))
  (funcall intr (cmbn 2 1 7))
  (funcall intr (cmbn 3))
  (funcall intr (cmbn 3 1 15))
  (funcall intr (cmbn 3 1 'new 1 15))
  (funcall intr (cmbn 3 1 'new -1 15))
  (funcall intr (cmbn 3 -1 'new 1 15))
  (funcall intr (cmbn 3 -1 'new -1 15))
|#
 
(DEFUN CHCM-DISK-PASTING (chcm dmns new bndr)
  (declare
    (type chain-complex chcm)
    (fixnum dmns)
    (symbol new)
    (type cmbn bndr))
  (the chain-complex
    (with-slots (cmpr basis dffr) chcm
      (declare
       (type cmprf cmpr)
       (type basis basis)
       (type morphism dffr))
      (let ((rslt (build-chcm
		   :cmpr (disk-pasting-cmpr cmpr new)
		   :basis (disk-pasting-basis basis dmns new)
		   :intr-dffr (disk-pasting-intr-dffr dffr dmns new bndr)
		   :strt :cmbn
		   :orgn `(chcm-disk-pasting ,chcm ,dmns ,new ,bndr))))
	(declare (type chain-complex rslt))
	(when (slot-boundp chcm 'bsgn)
	  (setf (slot-value rslt 'bsgn) (slot-value chcm 'bsgn)))
	rslt))))

#|
  (setf c (delta 3))
  (setf s3 (chcm-disk-pasting c 3 'new (? c 3 15)))
  (homology s3 0 5))
|#

(DEFUN DISK-PASTING-FACE (cmpr face dmns new faces)
  (declare
    (type cmprf cmpr)
    (type face face)
    (fixnum dmns)
    (symbol new)
    (list faces))
  (unless (= (1+ dmns) (length faces))
    (error "In DISK-PASTING, non-coherent arguments."))
  (mapl #'(lambda (mark)
	    (declare (list mark))
	    (unless (typep (car mark) 'absm)
	      (setf (car mark) (absm 0 (car mark)))))
	faces)
  (flet ((rslt (indx dmns2 gmsm)
	   (declare
	     (fixnum indx dmns2)
	     (type gmsm gmsm))
	   (unless (= dmns dmns2)
	     (return-from rslt
	       (funcall face indx dmns2 gmsm)))
	   (if (eq gmsm new)
	       (nth indx faces)
	     (funcall face indx dmns gmsm))))
    (unless (check-faces cmpr #'rslt dmns new)
      (error "The new simplicial-set is not constructed."))
    (the face #'rslt)))

#|
  (cat-init)
  (setf c (delta 3))
  (setf face (disk-pasting-face (cmpr c) (face c)
                3 'new (list 14 (absm 0 13) 11 7)))
  (funcall face 0 2 7)
  (funcall face 0 3 15)
  (dotimes (i 4) (print (funcall face i 3 'new)))
|#

(DEFUN DISK-PASTING (smst dmns new faces)
  (declare
    (type simplicial-set smst)
    (fixnum dmns)
    (symbol new)
    (list faces))
  (the simplicial-set
    (with-slots (cmpr basis bsgn face dffr) smst
      (declare
       (type cmprf cmpr)
       (type basis basis)
       (type gmsm bsgn)
       (type face face)
       (type morphism dffr))
      (let ((new-face (disk-pasting-face (cmpr smst) face
					 dmns new faces))
	    (new-bndr (zero-cmbn (1- dmns))))
	(declare
	  (type face new-face)
	  (type cmbn new-bndr))
	(do ((mark faces (cdr mark))
	     (sign 1 (- sign)))
	    ((endp mark))
	    (declare
	      (list mark)
	      (fixnum sign))
	  (let ((absm (car mark)))
	    (declare (type absm absm))
	    (with-absm (dgop gmsm) absm
	      (unless (plusp dgop)
		(dstr-add-term-to-cmbn cmpr sign gmsm new-bndr)))))
	(build-smst
	 :cmpr (disk-pasting-cmpr cmpr new)
	 :basis (disk-pasting-basis basis dmns new)
	 :bspn bsgn
	 :face new-face
	 :intr-bndr (disk-pasting-intr-dffr dffr dmns new new-bndr)
	 :bndr-strt :cmbn
	 :orgn `(disk-pasting ,smst ,dmns ,new ,faces))))))

#|
  (setf d2 (delta 2))
  (setf s2 (disk-pasting d2 2 'new '(6 5 3)))
  (homology s2 0 4)
  (setf s2xs2 (crts-prdc s2 s2))
  (homology s2xs2 0 6)
|#

(DEFUN MRPH-DISK-PASTING-INTR (mrph trgt-cmpr dmns new new-im)
  (declare
    (type morphism mrph)
    (type cmprf trgt-cmpr)
    (fixnum dmns)
    (symbol new)
    (type cmbn new-im))
  (let ((mrph-degr (degr mrph)))
    (declare (fixnum mrph-degr))
    (flet ((rslt (cmbn)
	     (declare (type cmbn cmbn))
	     (with-cmbn (degr list) cmbn
	       (unless (= degr dmns)
		 (return-from rslt
		   (cmbn-? mrph cmbn)))
	       (unless list
		 (return-from rslt
		   (zero-cmbn (+ degr mrph-degr))))
	       (unless (eq new (-gnrt list))
		 (return-from rslt
		   (cmbn-? mrph cmbn)))
	       (2cmbn-add trgt-cmpr
		 (n-cmbn (-cffc list) new-im)
		 (cmbn-? mrph
			 (make-cmbn :degr degr
				    :list (rest list)))))))
      (the intr-mrph #'rslt))))

#|
  (setf m (idnt-mrph (delta 3)))
  (setf intr
        (mrph-disk-pasting-intr m (cmpr (delta 3))
                                3 'new (cmbn 3 -1 15)))
  (funcall intr (cmbn 2 3 7))
  (funcall intr (cmbn 3))
  (funcall intr (cmbn 3 4 15))
  (funcall intr (cmbn 3 1 'new 1 15))
  (funcall intr (cmbn 3 -1 'new 1 15))
|#

(DEFUN MRPH-DISK-PASTING (mrph new-sorc new-trgt dmns new new-im)
  (declare
    (type morphism mrph)
    (type chain-complex new-sorc new-trgt)
    (fixnum dmns)
    (symbol new)
    (type cmbn new-im))
  (the morphism
    (build-mrph
      :sorc new-sorc :trgt new-trgt :degr (degr mrph)
      :intr (mrph-disk-pasting-intr mrph (cmpr new-trgt)
				    dmns new new-im)
      :strt :cmbn
      :orgn `(mrph-disk-pasting ,mrph ,new-sorc ,new-trgt
				,dmns ,new ,new-im))))

#|
  (setf d (delta 3))
  (setf m (idnt-mrph d))
  (setf sorc (chcm-disk-pasting d 3 'new (? d 3 15)))
  (setf nm (mrph-disk-pasting m sorc sorc 3 'new (cmbn 3 1 'new)))
  (? nm (cmbn 3 2 'new 3 15))
|#

(DEFUN HMEQ-DISK-PASTING (hmeq dmns new bndr &key new-lbcc)
  (declare
    (type homotopy-equivalence hmeq)
    (fixnum dmns)
    (symbol new)
    (type cmbn bndr)
    (type (or null chain-complex) new-lbcc))
  (let* ((lg (lg hmeq))
	 (rf (rf hmeq))
	 (rh (rh hmeq))
	 (t-bndr (cmbn-? lg bndr))
	 (rb-bndr (cmbn-? rf t-bndr))
	 (new-lbcc (or new-lbcc
		       (chcm-disk-pasting (lbcc hmeq)
					  dmns new bndr)))
	 (new-tcc (chcm-disk-pasting (tcc hmeq)
				      dmns new t-bndr))
	 (new-rbcc (chcm-disk-pasting (rbcc hmeq)
				      dmns new rb-bndr))
	 (1+dmns (1+ dmns)))
    (declare
      (type morphism lg rf rh)
      (type cmbn t-bndr rb-bndr)
      (type chain-complex new-lbcc new-tcc new-rbcc)
      (fixnum 1+dmns))
    (build-hmeq
      :lrdct (build-rdct
	       :f (mrph-disk-pasting (lf hmeq) new-tcc new-lbcc
				     dmns new (cmbn dmns 1 new))
	       :g (mrph-disk-pasting lg new-lbcc new-tcc
				     dmns new (cmbn dmns 1 new))
	       :h (mrph-disk-pasting (lh hmeq) new-tcc new-tcc
				     dmns new (zero-cmbn 1+dmns)))
      :rrdct (build-rdct
	       :f (mrph-disk-pasting rf new-tcc new-rbcc
				     dmns new (cmbn dmns 1 new))
	       :g (mrph-disk-pasting (rg hmeq) new-rbcc new-tcc
				     dmns new
				     (make-cmbn
				      :degr dmns
				      :list (cons (term 1 new)
						  (cmbn-list
						   (cmbn-opps
						    (cmbn-? rh t-bndr))))))
	       :h (mrph-disk-pasting rh new-tcc new-tcc
				     dmns new (zero-cmbn 1+dmns)))
      :orgn `(hmeq-disk-pasting ,hmeq ,dmns ,new ,bndr))))
				     
#|
(cat-init)
(setf tcc
      (build-chcm
       :cmpr #'s-cmpr
       :basis #'(lambda (degr)
		  (case degr
			(0 (list 'a))
			(1 (list 'b))
			(otherwise nil)))
       :intr-dffr #'(lambda (degr gnrt)
		      (if (= 1 degr)
			  (cmbn 0 1 'a)
			(zero-cmbn (1- degr))))
       :strt :gnrt
       :orgn '(z-z)))
(setf bcc
      (build-chcm
       :cmpr #'s-cmpr
       :basis #'(lambda (degr) nil)
       :intr-dffr #'(lambda (degr gnrt) (error "Impossible."))
       :strt :gnrt
       :orgn '(zero)))
(setf rh (build-mrph
	  :sorc tcc :trgt tcc :degr +1
	  :intr #'(lambda (degr gnrt)
		    (if (zerop degr)
			(cmbn 1 1 'b)
		      (zero-cmbn 2)))
	  :strt :gnrt
	  :orgn '(rh)))
(setf hmeq (build-hmeq
	    :lrdct (trivial-rdct tcc)
	    :rrdct (build-rdct
		    :f (zero-mrph tcc bcc 0)
		    :g (zero-mrph bcc tcc 0)
		    :h rh
		    :orgn '(rrdct))))
(setf nhmeq (hmeq-disk-pasting hmeq 1 'new (cmbn 0 1 'a)))
(pre-check-rdct (lrdct nhmeq))
(setf *tc* (cmbn 0 1 'a))
(setf *bc* *tc*)
(check-rdct)
(setf *tc* (cmbn 1 1 'new 10 'b))
(setf *bc* *tc*)
(check-rdct)
(pre-check-rdct (rrdct nhmeq))
(setf *bc* (zero-cmbn 0))
(check-rdct)
(setf *tc* (cmbn 0 1 'a))
(check-rdct)
|#

(DEFMETHOD SEARCH-EFHM (smst (orgn (eql 'disk-pasting)))
  (declare (type simplicial-set smst))
  (the homotopy-equivalence
    (destructuring-bind (old-smst dmns new faces) (rest (orgn smst))
			(declare
			  (type simplicial-set old-smst)
			  (fixnum dmns)
			  (symbol new)
			  (ignore faces))
      (hmeq-disk-pasting (efhm old-smst)
			 dmns new (? smst dmns new)
			 :new-lbcc smst))))

#|
(cat-init)
(setf d (delta 2))
(setf s2 (disk-pasting d 2 'new '(6 5
  3)))
(homology s2 0 4)
|#
