read-records:
	./run build read-records read-record count-chars write-newline

write-records:
	./run build write-records write-record

clean:
	rm -r ./build/*

all: read-records write-records