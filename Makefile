all:
	swipl -g main -q -o flp22-log -c flp22-log.pl

clean:
	rm -f flp22-log

run:
	./flp22-log

pack: clean
	zip flp-log-xkomar33.zip flp22-log.pl Makefile README tests/*