def classify_triangle(a, b, c):
    """
    Classify a triangle based on the lengths of its sides.
    
    Args:
        a, b, c: The lengths of the three sides
        
    Returns:
        A string describing the triangle type
    """
    # Check if the sides form a valid triangle (triangle inequality)
    if a <= 0 or b <= 0 or c <= 0:
        return "Invalid: All sides must be positive numbers"
    
    if a + b <= c or a + c <= b or b + c <= a:
        return "Not a triangle: Does not satisfy triangle inequality"
    
    # Classify the triangle type
    if a == b == c:
        return "Equilateral triangle"
    elif a == b or b == c or a == c:
        return "Isosceles triangle"
    else:
        return "Scalene triangle"


def main():
    """Main function to get user input and classify the triangle."""
    print("Triangle Classifier")
    print("=" * 40)
    
    try:
        a = float(input("Enter the length of side 1: "))
        b = float(input("Enter the length of side 2: "))
        c = float(input("Enter the length of side 3: "))
        
        result = classify_triangle(a, b, c)
        print(f"\nResult: {result}")
        
    except ValueError:
        print("Error: Please enter valid numeric values")


if __name__ == "__main__":
    main()
