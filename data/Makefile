.PHONY: font initial_screen

all: font initial_screen

font:
	$(MAKE) -C font

initial_screen:
	$(MAKE) -C initial_screen

clean:
	$(MAKE) -C font clean
	$(MAKE) -C initial_screen clean
	rm -f extended_videotex.txt initial_screen.txt

