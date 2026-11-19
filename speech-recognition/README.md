# Speech recognition (PyTorch)

Three notebooks, from classifying single audio frames to transcribing full utterances.

| Notebook | Task | Model |
| --- | --- | --- |
| `1_frame_level_phoneme_classification.ipynb` | Predict the phoneme for each 10 ms frame of speech from MFCC features | Multi-layer perceptron that sees a context window of neighbouring frames |
| `2_seq2seq_ctc_speech_recognition.ipynb` | Transcribe utterances into phoneme sequences without frame-level labels | Pyramidal bidirectional LSTM encoder with locked dropout, trained with CTC loss and decoded with beam search |
| `3_attention_based_speech_recognition.ipynb` | Transcribe LibriSpeech audio into characters | Listen, Attend and Spell: Transformer and pyramidal-LSTM listener, attention, and an autoregressive speller decoder |

**Result:** the CTC model reaches a validation Levenshtein distance of about 5.3 (edit distance between predicted and true phoneme sequences).

**Also used:** custom PyTorch `Dataset` and `DataLoader` with padding and packing, positional encoding, multi-head attention, teacher forcing, beam search, mixed-precision GPU training, and experiment tracking with Weights & Biases.
