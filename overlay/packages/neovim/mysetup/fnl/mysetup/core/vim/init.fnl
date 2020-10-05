(->> (require :mysetup.core.vim.runtime)
     (local {: join-if-table
             : register-if-function
             : vim!
             : fmt!}))
(->> (require :mysetup.core.vim.au)
     (local {: au : augroup}))
(->> (require :mysetup.core.vim.attrs)
     (local {: g! : o! : bo! : wo!}))
(->> (require :mysetup.core.vim.mappers)
     (local {: map! : icmap! : nmap! : vmap! : smap!
             : xmap! : omap! : imap! : lmap! : cmap!
             : tmap!}))

{: join-if-table : register-if-function
 : vim! : fmt!
 : au : augroup
 : g! : o! : bo! : wo!
 : map! : icmap! : nmap! : vmap! : smap!
 : xmap! : omap! : imap! : lmap! : cmap!
 : tmap!}
