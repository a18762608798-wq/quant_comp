import numpy as np
import matplotlib.pyplot as plt

x_array = [1, 2, 3]
y_array = [4, 5, 6]
plt.plot(x_array, y_array, label='cases')
plt.legend(loc='upper left')
plt.title('title')
plt.xlabel('X')
plt.ylabel('Y')
plt.show()
