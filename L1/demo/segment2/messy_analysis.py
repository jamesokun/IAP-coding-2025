import numpy as np
import pandas as pd

# This script is intentionally messy for a cleanup demo.

np.random.seed(7)

# fake data
n=300
x1=np.random.normal(size=n)
x2=np.random.normal(size=n)
noise=np.random.normal(scale=2.0,size=n)
# y = 1 + 2*x1 - 1.5*x2 + noise

y=1+2*x1-1.5*x2+noise

# make a DataFrame
D=pd.DataFrame({"x1":x1,"x2":x2,"y":y})

# messy transformation 1
D["x1_sq"]=D.x1*D.x1
D["x2_sq"]=D.x2*D.x2
D["sumx"]=D.x1 + D.x2

# repeated logic
D["x1_sq2"]=D["x1"]**2
D["x2_sq2"]=D["x2"]**2
D["sumx2"]=D["x1"]+D["x2"]

# a quick split
train=D.sample(frac=0.7,random_state=3)
test=D.drop(train.index)

# hand-rolled OLS (ugly)
X=train[["x1","x2"]].values
X=np.column_stack([np.ones(len(X)),X])
Y=train["y"].values
beta=np.linalg.inv(X.T@X)@(X.T@Y)

# predict on test
Xt=test[["x1","x2"]].values
Xt=np.column_stack([np.ones(len(Xt)),Xt])
yp= Xt@beta

# evaluation
mse=((test["y"].values-yp)**2).mean()

print("beta:",beta)
print("mse:",mse)

# extra dead code
if False:
    print(D.head())
