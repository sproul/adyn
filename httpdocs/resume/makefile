all:	build

build:	$(java_modules)
	make $(java_modules)
	java apply_xsl list_projects.xsl list_projects.xml list_projects.pm
	head.exe list_projects.pm

clean:
	rm *.class

java_modules = \
	apply_xsl.class


.SUFFIXES:
.SUFFIXES: .class .java .html .htm


.java.class :
	javac -g -deprecation $<
