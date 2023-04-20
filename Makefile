all:
	swipl -g main -q -o flp22-log -c flp22-log.pl

clean:
	rm -f flp22-log