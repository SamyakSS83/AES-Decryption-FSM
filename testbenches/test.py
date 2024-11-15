import numpy as np

def matrix_to_hex_string(matrix):
    """Convert a 4x4 matrix to a hex string."""
    result = ''
    for i in range(4):
        for j in range(4):
            result += f"{matrix[i][j]:02x}"
    return result.upper()

def convert_to_ascii_hex(hex_string):
    """Convert hex string to ASCII representation of hex values."""
    result = ""
    for i in range(0, len(hex_string), 2):
        ascii_val = int(hex_string[i:i + 2], 16)
        if ascii_val >= ord('0') and ascii_val <= ord('9'):
            result += chr(ascii_val)
        elif ascii_val >= ord('A') and ascii_val <= ord('F'):
            result += chr(ascii_val)
        elif ascii_val >= ord('a') and ascii_val <= ord('f'):
            result += chr(ascii_val)
        else:
            result += '-'
    return result

def create_state_matrix(data):
    """Create a 4x4 state matrix from input data."""
    return np.array(data).reshape(4, 4)

def create_state_matrix_2(data):
    """Create a 4x4 state matrix from input data."""
    return np.array(data).reshape(4, 4).T

def inv_shift_rows(state):
    """Perform inverse shift rows operation."""
    state[1] = np.roll(state[1], 1)
    state[2] = np.roll(state[2], 2)
    state[3] = np.roll(state[3], 3)
    return state

def inv_sub_bytes(state, inv_sbox):
    """Perform inverse sub bytes operation using inverse S-box."""
    result = np.zeros_like(state, dtype=np.uint8)
    for i in range(4):
        for j in range(4):
            value = state[i][j]
            row = value >> 4
            col = value & 0x0F
            result[i][j] = inv_sbox[row * 16 + col]
    return result

def gf_multiply(x, y):
    """Multiply two numbers in GF(2^8)."""
    result = 0
    for i in range(8):
        if y & (1 << i):
            result ^= x << i
    for i in range(7, -1, -1):
        if result & (1 << (i + 8)):
            result ^= 0x11B << i
    return result

def inv_mix_columns(state):
    """Perform inverse mix columns operation."""
    fixed_matrix = [
        [0x0E, 0x0B, 0x0D, 0x09],
        [0x09, 0x0E, 0x0B, 0x0D],
        [0x0D, 0x09, 0x0E, 0x0B],
        [0x0B, 0x0D, 0x09, 0x0E]
    ]

    result = np.zeros_like(state, dtype=np.uint8)
    for col in range(4):
        for row in range(4):
            sum = 0
            for i in range(4):
                sum ^= gf_multiply(fixed_matrix[row][i], state[i][col])
            result[row][col] = sum
    return result

def add_round_key(state, round_key):
    """Add round key to state."""
    return state ^ round_key

def aes_decrypt(cipher_text, round_keys, inv_sbox):
    """Perform AES decryption."""
    state = create_state_matrix_2(cipher_text)

    round_key_matrices = []
    for i in range(0, len(round_keys), 16):
        round_key_matrices.append(create_state_matrix_2(round_keys[i:i + 16]))

    state = add_round_key(state, round_key_matrices[9])
    state = inv_shift_rows(state)
    state = inv_sub_bytes(state, inv_sbox)
    print(f"Round 0 result: {matrix_to_hex_string(state)}")
    for round_num in range(8, 0, -1):
        state = add_round_key(state, round_key_matrices[round_num])
        state = inv_mix_columns(state)
        state = inv_shift_rows(state)
        state = inv_sub_bytes(state, inv_sbox)
        print(f"Round {9-round_num} result: {matrix_to_hex_string(state)}")

    state = add_round_key(state, round_key_matrices[0])
    hex_result = matrix_to_hex_string(state)
    print(f"Decrypted hex result: {hex_result}")
    return convert_to_ascii_hex(hex_result)

def decrypt_aes():
    """Decrypt AES using hardcoded values."""

    # Hardcoded lists for input data
    cipher_text = ['0x5a', '0xf5', '0xfd', '0x86', '0xd4', '0xf3', '0x92', '0x80', '0xcb', '0x9b', '0x88', '0x64', '0x11', '0x88', '0x6b', '0xde']
    
    round_keys = [
    ]
    
    inv_sbox = [
        # Inverse S-box values as a single list of 256 integers
        # For example: [0x52, 0x09, 0x6A, 0xD5, ...] up to 256 elements
    ]

    result = aes_decrypt(cipher_text, round_keys, inv_sbox)
    print(f"Decrypted result: {result}")

if __name__ == "__main__":
    decrypt_aes()
