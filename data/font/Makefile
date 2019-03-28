extended_videotex.txt: extended_videotex.png
	python png_to_bin.py
	cp extended_videotex.txt ..

extended_videotex.png: extended_videotex.svg
	inkscape -f extended_videotex.svg -e extended_videotex.png

clean:
	rm -f extended_videotex.png extended_videotex.txt

