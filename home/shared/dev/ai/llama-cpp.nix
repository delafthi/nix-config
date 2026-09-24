{
  services.llama-cpp = {
    enable = true;
    settings = {
      jinja = true;
      port = 11434;
      ctx-size = 32768;
      hf-repo = "ggml-org/gemma-4-E4B-it-GGUF:Q8_0";
    };
  };
}
