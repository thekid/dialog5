VERSION?=$(shell cat VERSION)

compile: compile-main compile-test

test: compile
	unittest de.thekid.dialog.unittest.**

compile-main: dist/main dist/test
	xcc -p rad -o dist/main -sp src/main/xp src/main/xp

compile-test: dist/main dist/test
	xcc -p rad -o dist/test -sp src/test/xp src/test/xp

dist:	compile
	cd dist/main && xar cvf ../dialog-$(VERSION).xar .
	echo dist/dialog-$(VERSION).xar > class.pth
	cd .. && zip -r dialog/dist/dialog-$(VERSION).zip dialog/dist/dialog-$(VERSION).xar dialog/xsl dialog/doc_root dialog/etc dialog/data dialog/class.pth -x \*.svn\* -x .cvsignore
	rm class.pth

dist/main:
	mkdir -p $@

dist/test:
	mkdir -p $@

clean:
	-rm -rf dist/main/* dist/test/*

release:	dist
	scp dist/dialog-$(VERSION).zip xpdoku@xp-forge.net:/home/httpd/xp.php3.de/doc_root/downloads/projects/www/
