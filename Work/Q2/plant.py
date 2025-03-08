import argparse
import matplotlib.pyplot as plt

def plot_plant_data(plant, heights, leaf_counts, dry_weights):
    plt.figure(figsize=(10, 6))
    plt.scatter(heights, leaf_counts, color='b', s=100)
    plt.title(f'Height vs Leaf Count for {plant}', fontsize=14, fontweight='bold')
    plt.xlabel('Height (cm)')
    plt.ylabel('Leaf Count')
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.savefig(f"{plant}_scatter.png")
    plt.close()

    plt.figure(figsize=(10, 6))
    plt.hist(dry_weights, bins=len(dry_weights), color='g', edgecolor='black')
    plt.title(f'Histogram of Dry Weight for {plant}')
    plt.xlabel('Dry Weight (g)')
    plt.ylabel('Frequency')
    plt.grid(True)
    plt.savefig(f"{plant}_histogram.png")
    plt.close()

    plt.figure(figsize=(10, 6))
    plt.plot(heights, dry_weights, marker='o', color='r')
    plt.title(f'{plant} Height Over Time')
    plt.xlabel('Height (cm)')
    plt.ylabel('Dry Weight (g)')
    plt.grid(True)
    plt.savefig(f"{plant}_line_plot.png")
    plt.close()

    print(f"Generated plots for {plant}:")
    print(f"Scatter plot saved as {plant}_scatter.png")
    print(f"Histogram saved as {plant}_histogram.png")
    print(f"Line plot saved as {plant}_line_plot.png")

def main():
    parser = argparse.ArgumentParser(description="Generate plant growth plots.")
    parser.add_argument("--plant", type=str, required=True, help="Plant name")
    parser.add_argument("--height", type=float, nargs="+", required=True, help="List of plant heights")
    parser.add_argument("--leaf_count", type=int, nargs="+", required=True, help="List of leaf counts")
    parser.add_argument("--dry_weight", type=float, nargs="+", required=True, help="List of dry weights")

    args = parser.parse_args()

    if not (len(args.height) == len(args.leaf_count) == len(args.dry_weight)):
        print("Error: All input lists must be of the same length!")
        return

    plot_plant_data(args.plant, args.height, args.leaf_count, args.dry_weight)

if __name__ == "__main__":
<<<<<<< HEAD
    main()
=======
    main()
>>>>>>> BR_Q4
