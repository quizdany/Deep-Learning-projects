# Face classification and verification (PyTorch)

Two related tasks on a large face dataset:

1. **Classification:** identify which of thousands of known people appears in an image.
2. **Verification:** decide whether two face images show the same person, including people never seen in training, by comparing learned embeddings.

**Model:** a ResNet built from residual blocks. It is trained with cross-entropy plus **center loss**, which pulls embeddings of the same person together so that verification works on unseen identities.

**Techniques:** data augmentation, mixed-precision training (`autocast`), learning-rate scheduling, and embedding similarity for verification.
