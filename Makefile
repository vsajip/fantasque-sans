SOURCES=$(wildcard Sources/*.sfdir)
BASENAMES=$(patsubst Sources/%.sfdir,%,$(SOURCES))
TTF_FILES=$(patsubst %,TTF/%.ttf,$(BASENAMES))
OTF_FILES=$(patsubst %,OTF/%.otf,$(BASENAMES))
SVG_FILES=$(patsubst %,Webfonts/%.svg,$(BASENAMES))
WOFF_FILES=$(patsubst %,Webfonts/%.woff,$(BASENAMES))
WOFF2_FILES=$(patsubst %,Webfonts/%.woff2,$(BASENAMES))
EOT_FILES=$(patsubst %,Webfonts/%.eot,$(BASENAMES))
CSS_FRAGMENTS=$(patsubst %,Webfonts/%-decl.css,$(BASENAMES))
CSS_FILE=Webfonts/stylesheet.css

INSTALLED_TTF_FILES=$(patsubst %,~/.fonts/%.ttf,$(BASENAMES))

all: $(TTF_FILES)

OTF/%.otf TTF/%.ttf Webfonts/%.svg Webfonts/%.eot Webfonts/%.woff Webfonts/%.woff2 Webfonts/%-decl.css: Sources/%.sfdir
	mkdir -p OTF TTF Webfonts
	./validate-generate "$*"
	# TODO determine perfect parameters
	ttfautohint "TTF/$*.ttf" "TTF/$*.hinted.ttf"
	mv "TTF/$*.hinted.ttf" "TTF/$*.ttf"
	sfnt2woff "OTF/$*.otf"
	mv "OTF/$*.woff" Webfonts
	woff2_compress "TTF/$*.ttf"
	mv "TTF/$*.woff2" Webfonts
	ttf2eot "TTF/$*.ttf" > "Webfonts/$*.eot"

$(CSS_FILE): $(CSS_FRAGMENTS)
	cat $(foreach v,$(CSS_FRAGMENTS),$(if $(findstring Mono,$v),$v)) > $(CSS_FILE)

.PHONY: install clean zips zip-mono zip-prop
install: $(INSTALLED_TTF_FILES)

$(INSTALLED_TTF_FILES): $(TTF_FILES)
	mkdir -p ~/.fonts/
	cp $^ ~/.fonts/
	fc-cache -f

zips: zip-mono zip-prop

zip-mono: $(TTF_FILES) $(OTF_FILES) $(SVG_FILES) $(EOT_FILES) $(WOFF_FILES) $(WOFF2_FILES) $(SOURCES) $(CSS_FILE)
	zip FantasqueSansMono.zip LICENSE.txt README.md Webfonts/README.md $(CSS_FILE) $(foreach v,$^,$(if $(findstring Mono,$v),$v))
	tar czvf FantasqueSansMono.tar.gz LICENSE.txt README.md Webfonts/README.md $(CSS_FILE) $(foreach v,$^,$(if $(findstring Mono,$v),$v))


zip-prop: $(TTF_FILES) $(OTF_FILES) $(SVG_FILES) $(EOT_FILES) $(WOFF_FILES) $(WOFF2_FILES) $(SOURCES)
	zip FantasqueSans.zip LICENSE.txt README.md Webfonts/README.md $(foreach v,$^,$(if $(findstring Mono,$v),,$v))
	tar czvf FantasqueSans.tar.gz LICENSE.txt README.md Webfonts/README.md $(foreach v,$^,$(if $(findstring Mono,$v),,$v))

clean:
	rm -f TTF/*.ttf *.zip OTF/* Webfonts/*.eot Webfonts/*.woff Webfonts/*.woff2 Webfonts/*.svg Webfonts/*.css

test: $(INSTALLED_TTF_FILES)
	gvim -f ~/Developpement/Système/kernel-base/shared/printf.c
