ibis=${1}
bfile=${2}
threads=${3}

$ibis -b $bfile -t $threads -printCoef
