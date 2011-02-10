set -x
hadoop jar /usr/local/hadoop/contrib/streaming/hadoop-0.20.2-streaming.jar \
 -input $1 \
 -output $2 \
 -file emit_cc_to_neighbours.rb \
 -mapper emit_cc_to_neighbours.rb \
 -file min_cc_id_from_neighbours.rb \
 -reducer min_cc_id_from_neighbours.rb