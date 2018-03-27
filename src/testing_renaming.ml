type attr_bind = (string*string) * string option
type data = {mutable attr : attr_bind list} 

let attr = [(("e", "Year"), None); (("e", "Make"), None); (("e", "Model"), None);
             (("e", "Description"), None); (("e", "Price"), None); (("f", "Year"), None);
             (("f", "Make"), None)]
           


  let hash = Hashtbl.create 10
          

       let rec rename id hash = function
          | ((rel, att), al) :: xs when Hashtbl.mem hash att ->  
                  let ix = Hashtbl.find hash att in 
                  begin
                      Hashtbl.replace hash att (ix+1);
                      ((id, att ^ ":" ^ (string_of_int ix)), al) :: (rename id hash xs)
                  end
          | ((rel, att), al) :: xs ->
                begin
                   Hashtbl.add hash att 1;
                   ((id, att), al) :: (rename id hash xs)
                end
          | [] -> []

let _ = rename "yo" hash attr
