# AI Developer Conventions & Workflow

When making changes to this codebase, please adhere to the following rules:

## 1. Testing Requirement
- **Always run the tests** after modifying the codebase.
- Tests can be run from the `src` directory using the command: `python -m pytest tests/`
- **Do not consider a task complete** until all tests pass successfully.
- If a change causes a test to fail, debug and fix the issue before moving on.
- When adding new features or transforms, write appropriate tests in the `tests/` directory to cover the new behavior without generating actual `.wav` files (use mocking for I/O).

## 2. Iterative Development
- Make small, incremental changes as outlined in `PROJECT_GOAL.md`.

## 3. Comments
- Comments in the code should be avoided if possible. The code should be self-documenting and expressive so as to make the intent clear without needing a comment.
- In cases where the code might need explanation, then comments can be used, but they must explain the WHY and not the WHAT. 
- Comments that only explain what the code is doing are redundant and not helpful unless what the code is doing is not intuitive.

### Example of bad comments:
```python
for arg_name, func, takes_value in transform_specs:
    val = getattr(parsed_args, arg_name)
    if takes_value:
        # For value-taking flags, check if val is not None
        if val is not None:
            transforms_to_apply.append(lambda tones, f=func, v=val: f(tones, v))
    else:
        # For boolean flags, check if val is True
        if val:
            transforms_to_apply.append(func)
```

### Example of good comments:
```python
def test_mix_with_normalization(self):
    # Why: 16-bit PCM audio has a strict maximum value of 32767. 
    # If multiple playing tracks sum to a value higher than this, the integer overflows
    # and causes severe audio distortion (clipping). We must ensure the mixer prevents this.
    loud_track_1 = np.array([20000, -20000], dtype=np.int16)
    loud_track_2 = np.array([20000, -20000], dtype=np.int16)
    
    result = mix_waveforms([loud_track_1, loud_track_2])
    
    # Why: The raw mathematical sum [40000, -40000] is too large. 
    # The mixer must detect this and proportionally scale the entire array down 
    # so the highest peak rests exactly at the safe 16-bit limit (32767).
    assert len(result) == 2
    assert result[0] == 32767
    assert result[1] == -32767
```

## 4. Magic Strings and Magic Numbers
- Where possible, magic strings and numbers should not be hard-coded, but be extracted to variables with descriptive and meaningful names that describes their purpose and meaning.
- The names of the variables should be all caps and in CAMEL_CASE.

## 5. Expressive Code
- Code should be expressive and self documenting.
- Write the code so you don't even need a lot of comments, since the names, variables and sequence it takes is telling an obvious story of what the intention and purpose of the code is.
- Names of variables and functions should be descriptive and express the intent and purpose.
- Do not use generic names like "data" or "stuff".
- Names of variables and functions should not lie. They should indicate clearly and honestly what they represent, what the variable's purpose is and what the function is doing.