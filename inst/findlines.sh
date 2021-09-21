convert $1.pdf png:$1
for f in $1-*; do
convert $f -flatten -resize 1X1000! -black-threshold 99% -white-threshold 10% -negate -morphology Erode Diamond -morphology Thinning:-1 Skeleton -black-threshold 50% txt:- > $f-raw.txt;
done
