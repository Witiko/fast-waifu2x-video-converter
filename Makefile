SHELL=/bin/bash

include configuration.mk

get_framerate=$(FFPROBE) -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate $(1)

frames-%-naive: %.mp4
	mkdir -p $(LARGE_STORAGE)/$@
	ln -s $(LARGE_STORAGE)/$@ $@
	$(FFMPEG) -i $< -f image2 $@/%06d.png
	find $@/ -name '*.png' | sort -t / -k 2 -n > $@/frames.txt

frames-%-2x-naive: frames-%-naive
	mkdir -p $(LARGE_STORAGE)/$@
	ln -s $(LARGE_STORAGE)/$@ $@
	$(WAIFU2X) -l $</frames.txt $(WAIFU2X_OPTIONS) -o $@/%06d.png
	rm -r $(LARGE_STORAGE)/$<
	rm $<

%2x-naive.mp4: frames-%-2x-naive %.mp4
	$(FFMPEG) -framerate $$($(call get_framerate,$(word 2,$^))) -i $</%06d.png -i $(word 2,$^) -map 0:v -map 1:a $(FFMPEG_OPTIONS) $@
	rm -r $(LARGE_STORAGE)/$<
	rm $<

frames-%: %.mp4
	mkdir -p $(LARGE_STORAGE)/$@
	ln -s $(LARGE_STORAGE)/$@ $@
	$(FFMPEG) -i $< -f image2 $@/%06d.png
	find $@/ -name '*.png' | sort -t / -k 2 -n > $@/frames.txt
	$(PYTHON) -m scripts.cluster_images $@/frames{,-representatives,-renames,-symlinks}.txt $(NUMBER_OF_CLUSTERS)

frames-%-2x: frames-%
	mkdir -p $(LARGE_STORAGE)/$@
	ln -s $(LARGE_STORAGE)/$@ $@
	$(WAIFU2X) -l $</frames-representatives.txt $(WAIFU2X_OPTIONS) -o $@/%06d.png
	echo Renaming cluster representatives
	(set -e; cd $@ && while read SOURCE DEST; do mv    $$SOURCE $$DEST; printf .; done) < $</frames-renames.txt  | pv -s `wc -l < $</frames-renames.txt ` > /dev/null
	echo Symlinking cluster members to representatives
	(set -e; cd $@ && while read SOURCE DEST; do ln -s $$SOURCE $$DEST; printf .; done) < $</frames-symlinks.txt | pv -s `wc -l < $</frames-symlinks.txt` > /dev/null
	rm -r $(LARGE_STORAGE)/$<
	rm $<

%2x.mp4: frames-%-2x %.mp4
	$(FFMPEG) -framerate $$($(call get_framerate,$(word 2,$^))) -i $</%06d.png -i $(word 2,$^) -map 0:v -map 1:a $(FFMPEG_OPTIONS) $@
	rm -r $(LARGE_STORAGE)/$<
	rm $<
