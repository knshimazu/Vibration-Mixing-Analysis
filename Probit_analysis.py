import numpy as np
import matplotlib.pyplot as plt
import statsmodels.api as sm
from scipy.stats import norm

from PIL import Image
import io

# Define the data
y = np.array([0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1])  # Outcome variable
X = np.array([0, 0, 0, 15, 15, 15, 30, 30, 30, 60, 60, 60, 100, 100, 100, 200, 200, 200])  # Predictor variable


# Add constant term for the intercept
X = sm.add_constant(X)

# Fit probit model
probit_model = sm.Probit(y, X)
probit_result = probit_model.fit()
# Generate predicted probabilities
X_range = np.linspace(np.min(X[:, 1]), np.max(X[:, 1]), 100)
X_range = sm.add_constant(X_range)
predicted_prob = probit_result.predict(X_range)

# Plot the data points
#plt.scatter(X[:, 1], y, color='blue', label='Data')
#plt.scatter(30,.66,color='blue')
#plt.scatter(60,.66,color='blue')

# Plot the probit model
plt.plot(X_range[:, 1], predicted_prob, color='black', label='Probit Model')

# Add a horizontal line at y = 0.95
plt.axhline(y=0.95, color='green', linestyle='--', label='95% confidence')

# Calculate intersection point
idx = np.argwhere(np.diff(np.sign(predicted_prob - 0.95))).flatten()
if len(idx) > 0:
    intersection_x = X_range[idx[0], 1]
    plt.plot(intersection_x, 0.95, 'ko', label='Intersection = 76.77')
    
# Add labels and legend
plt.xlabel('Copies per reaction (DNA)')
plt.ylabel('Probability of Outcome = 1')
#plt.title('Probit Model')
#plt.legend()
# Show plot
fig = plt.show()

# Print summary of the model
print(probit_result.summary())
fig.savefig('probit.tif')