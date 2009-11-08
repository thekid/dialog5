VERSION?=$(shell cat VERSION)

dist:
	cd src && xar cvf ../dialog-$(VERSION).xar .
	cd .. && zip -r dialog-$(VERSION).zip dialog/dialog-$(VERSION).xar dialog/xsl dialog/doc_root dialog/etc dialog/data -x \*.svn\* -x .cvsignore

clean:
	-rm ../dialog-*.zip dialog-*.xar

release:
	scp ../dialog-$(VERSION).zip xpdoku@xp-forge.net:/home/httpd/xp.php3.de/doc_root/downloads/projects/www/
