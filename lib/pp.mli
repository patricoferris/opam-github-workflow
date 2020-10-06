open Types

val job : Format.formatter -> job -> unit
(** Pretty prints a job *)

val workflow :
  ?drop_null:bool -> ('a -> Yaml.value) -> Format.formatter -> 'a t -> unit
(** Pretty prints a workflow. The user must supply a function for converting the
    type parameter to a yaml value. The [drop_nulls] argument can specifiy
    whether or not you want print null values in your yaml, the default being no *)
