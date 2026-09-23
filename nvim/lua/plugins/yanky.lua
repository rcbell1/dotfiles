-- LazyVim's yanky extra sets sync_with_ring = false over SSH, and p is
-- YankyPutAfter, so each Neovim pastes its own ring. With clipboard =
-- "unnamedplus", focus changes should pull the shared + register into the ring.
return {
  "gbprod/yanky.nvim",
  opts = {
    system_clipboard = {
      sync_with_ring = true,
    },
  },
}
