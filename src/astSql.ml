
type s = Select of (atts * rels * cond)
       | Minus of (s * s)
       | Union of (s * s)
and
     atts = CoupleAtt of attd * atts 
          | Single of attd
and
     attd = Lname of att
          | Sname of (att * string)
and
     att = string * string
and
     rels = CoupleRel of rel * rels 
          | SingleRel of rel
and
     rel = Filename of string
         | Newtable of s * string
and
     cond = OrCons of and_cond * cond 
          | SingleAnd of and_cond
and
     and_cond = AndCond of at_cond * and_cond
              | SingleAt of at_cond
and
     at_cond = Eq of att * att
             | Lt of att * att
             | In of att * s
             | NotIn of att * s


