#!/bin/bash
SCRIPT_PATH=$(dirname "$(realpath ${BASH_SOURCE[0]})")
CSV_FNAME=${SCRIPT_PATH}/url.csv
CSV_TMP_FNAME=${SCRIPT_PATH}/url.tmp.csv
CSV_FINAL_FNAME=${SCRIPT_PATH}/url.final.csv

[ -f "${CSV_FNAME}" ] || touch "${CSV_FNAME}"

if [ "X$1" == "Xshow" ] ; then
cp "${CSV_FNAME}" "${CSV_FINAL_FNAME}"
sed "s;{begin_date};$(date -v"-7d" "+%Y-%m-%d");g" "${CSV_FINAL_FNAME}" >"${CSV_TMP_FNAME}"
mv "${CSV_TMP_FNAME}" "${CSV_FINAL_FNAME}"
sed "s;{end_date};$(date -v"-1d" "+%Y-%m-%d");g" "${CSV_FINAL_FNAME}" >"${CSV_TMP_FNAME}"
mv "${CSV_TMP_FNAME}" "${CSV_FINAL_FNAME}"

awk -v "filterPattern=$2" -v"placeholderInput=$3" '
BEGIN {
	printf("{\"items\": [\n");
    gsub("\\*", ".*", filterPattern);
    if (length(placeholderInput) > 0) {
        split(placeholderInput, placeholderPairs, ",");
        for (placeholderIdx in placeholderPairs) {
            placeholderPair = placeholderPairs[placeholderIdx];
            split(placeholderPair, placeholderTuple, "=");
            placeholderKey = sprintf("{%s}", placeholderTuple[1]);
            placeholderMapping[placeholderKey] = placeholderTuple[2];
        }
    }
}
NF == 2 {
	if (length(filterPattern) == 0 || match($1, filterPattern) > 0) {
        if (length(placeholderMapping) > 0) {
            for (placeholderKey in placeholderMapping) {
                gsub(placeholderKey, placeholderMapping[placeholderKey], $2);
            }
        }
		printf("\t{\"arg\": \"%s\", \"title\": \"%s\", \"subtitle\": \"%s\"},\n", $2, $1, $2);
	}
}
END {
	printf("]}\n");
}
' "${CSV_FINAL_FNAME}"
exit
fi

[ -f "${CSV_FNAME}" ] || touch "${CSV_FNAME}"

awk -v "input_name=$1" -v "input_url=$2" '
NF == 2 && !AlreadyPrinted[$1] {
    if ($1 == input_name) {
        if (length(input_url) > 0) {
            printf("%s %s\n", input_name, input_url);
        }
    } else {
        printf("%s %s\n", $1, $2);
    }
    AlreadyPrinted[$1] = 1
}
END {
    if (!AlreadyPrinted[input_name] && length(input_url) > 0) {
        printf("%s %s\n", input_name, input_url);
    }
}
' "${CSV_FNAME}" > "${CSV_TMP_FNAME}"
mv "${CSV_TMP_FNAME}" "${CSV_FNAME}"