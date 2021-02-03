nums <- sample((10000:99999), 300)

write.table(nums, '/Users/juusu53/Documents/projects/kipupotilaat/data/kipuklinikka_subname_batch_2.csv', 
          row.names=FALSE, col.names = FALSE)


# to create subnums on server, run
#for n in $(cat kipuklinikka_subname_batch_2.csv);do mkdir -p subjects/$n;chmod 777 subjects/$n;touch subjects/$n/index.php;done
# sudo chown -R www-data ./subjects/* 