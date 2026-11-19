# Deep learning and database projects

Coursework and projects from my MS in Electrical & Computer Engineering (Data Science & Machine Learning) at Carnegie Mellon University.

| Project | What it shows | Tools |
| --- | --- | --- |
| [Speech recognition](speech-recognition/) | Three models of increasing power: frame-level phoneme classification, sequence-to-sequence recognition trained with CTC loss, and an attention-based encoder–decoder (Listen, Attend and Spell with Transformer encoder layers) | PyTorch, CUDA, LSTMs, Transformers, attention |
| [Face recognition](face-recognition/) | Face classification and verification with a ResNet trained with center loss | PyTorch, CNNs, mixed precision |
| [Road crash response database](road-crash-response-db/) | A PostgreSQL database that dispatches the nearest police officer and books the nearest hospital with free emergency rooms when a crash is reported, using geospatial triggers | PostgreSQL, PL/pgSQL, earthdistance |

The notebooks were written for Kaggle and Google Colab GPU runtimes. They download the course datasets from Kaggle, which needs a Kaggle API key.
