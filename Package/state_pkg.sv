package state_pkg;

typedef enum logic [1:0]{
  READY,
  EXEC,
  MEM_WAIT,
  DONE
    }warp_state;
endpackage