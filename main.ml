open Csv

let () = 
  let ic = of_channel (open_in "cars.csv") in
  let csv_file = input_all ic in
  print csv_file;;
