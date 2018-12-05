from sklearn.datasets import load_boston
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

import optuna
import numpy as np

boston = load_boston()
X, y = boston["data"], boston["target"]
# 訓練、テスト分割
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=114514)
n_train = int(X_train.shape[0] * 0.75)
X_train, X_val = X_train[:n_train], X_train[n_train:]
y_train, y_val = y_train[:n_train], y_train[n_train:]

# 標準化
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_val = scaler.transform(X_val)
X_test = scaler.transform(X_test)

# 目的関数
def objective(trial):
    # C
    svr_c = trial.suggest_loguniform('svr_c', 1e0, 1e2)
    # epsilon
    epsilon = trial.suggest_loguniform('epsilon', 1e-1, 1e1)
    # SVR
    svr = SVR(C=svr_c, epsilon=epsilon)
    svr.fit(X_train, y_train)
    # 予測
    y_pred = svr.predict(X_val)
    # CrossvalidationのMSEで比較（最大化がまだサポートされていない）
    return mean_squared_error(y_val, y_pred)


# optuna
study = optuna.create_study()
study.optimize(objective, n_trials=100)

# 最適解
print(study.best_params)
print(study.best_value)
print(study.best_trial)


