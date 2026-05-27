import pandas as pd
import numpy as np
import itertools

from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler, PowerTransformer
from sklearn.cluster import KMeans, AgglomerativeClustering, HDBSCAN
from sklearn.metrics import silhouette_score, davies_bouldin_score
from sklearn.model_selection import ParameterGrid

from scipy.spatial.distance import pdist, squareform

from pgmpy.estimators import PC
    
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
import seaborn as sns
import geopandas as gpd

import warnings
warnings.filterwarnings("ignore", category=FutureWarning)


def plot_distributions(df, savepath=None):
    """Plots histogram with density line in a 3x3 grid."""
    fig, axes = plt.subplots(3, 3, figsize=(14, 14))
    axes = axes.flatten()
    
    for i, col in enumerate(df.columns):
        sns.histplot(df[col], kde=True, ax=axes[i], color='skyblue')

    plt.tight_layout()
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


def plot_correlations(df, savepath=None): 
    """Calculates and plots a heatmap of the Pearson correlation matrix."""
    corr_matrix = df.corr()
    
    plt.figure(figsize=(9.5, 9))
    mask = np.triu(np.ones_like(corr_matrix, dtype=bool))    
    sns.heatmap(corr_matrix, mask=mask, 
                annot=True, fmt=".2f", 
                square=True, 
                linewidths=0.5,
                annot_kws={"size": 12, "weight": "bold"},
                cmap="vlag", cbar=None)
    
    plt.xticks(fontsize=12, rotation=45, ha='right')
    plt.yticks(fontsize=12, rotation=0)
    plt.xlabel("")
    plt.ylabel("")
    plt.tight_layout()
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


def plot_scatter(df, savepath=None): 
    """Plots pairwise scatter plots for numerical columns against each other dynamically."""
    cols = df.columns
    n = len(cols)
    fig, axes = plt.subplots(n, n, figsize=(4 * n, 4 * n))        
    for i in range(n):
        for j in range(n):
            ax = axes[i, j]
            if i == j:
                sns.histplot(df[cols[i]], kde=True, ax=ax, color='skyblue')
            else:
                sns.scatterplot(x=df[cols[j]], y=df[cols[i]], ax=ax, color='salmon', alpha=0.6)
            
            if i == n - 1: ax.set_xlabel(cols[j])
            else: ax.set_xlabel('')
            if j == 0: ax.set_ylabel(cols[i])
            else: ax.set_ylabel('')

    plt.tight_layout()
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


def plot_tsne(df, countries, perplexity=10, savepath=None):
    tsne = TSNE(n_components=2, perplexity=perplexity, max_iter=2500, random_state=42)
    tsne_results = tsne.fit_transform(df)
    
    idx_max_gdp = df['gdpp'].idxmax()
    idx_min_gdp = df['gdpp'].idxmin()
    idx_max_mort = df['child_mort'].idxmax()
    idx_max_life_exp = df['life_expec'].idxmax()
    idx_max_total_fer = df['total_fer'].idxmax()
    idx_min_total_fer = df['total_fer'].idxmin()
    
    highlight_indices = [idx_max_gdp, idx_min_gdp, idx_max_mort, idx_max_life_exp, idx_max_total_fer, idx_min_total_fer]
    highlight_colors = ['tab:green', 'tab:red', 'tab:orange', 'tab:blue', 'tab:olive', 'tab:cyan']

    highlight_names = [
        f"Max GDP: {countries[idx_max_gdp]}", 
        f"Min GDP: {countries[idx_min_gdp]}",
        f"Max Child Mort: {countries[idx_max_mort]}",
        f"Max Life Expec: {countries[idx_max_life_exp]}", 
        f"Max Total Fer: {countries[idx_max_total_fer]}", 
        f"Min Total Fer: {countries[idx_min_total_fer]}", 
    ]

    plt.figure(figsize=(10, 8))
    
    plt.scatter(tsne_results[:, 0], tsne_results[:, 1], color='lightgray', alpha=0.5, label='Other Countries')
    for idx, color, name in zip(highlight_indices, highlight_colors, highlight_names):
        plt.scatter(tsne_results[idx, 0], tsne_results[idx, 1], 
                    color=color, s=150, edgecolors='black', label=name, zorder=5)
        
    plt.xlabel('t-SNE Component 1', fontsize=12)
    plt.ylabel('t-SNE Component 2', fontsize=12)
    plt.legend(loc='best')
    plt.grid(True, linestyle='--', alpha=0.3)
    if savepath: 
        plt.savefig(savepath, bbox_inches='tight')
    plt.close()


palette = {'Standard Scaling': '#8cd98c', 'Power Transform': '#4da6ff'}

def plot_compared_distributions(combined_df, savepath=None):
    fig, axes = plt.subplots(3, 3, figsize=(12, 12))
    axes = axes.flatten()
    
    features = [col for col in combined_df.columns if col != 'Strategy']
    for i, col in enumerate(features):
        ax = axes[i]
        sns.kdeplot(ax=ax, data=combined_df, x=col, 
                    hue='Strategy', palette=palette, fill=True, alpha=0.15)
        
        ax.set_title(f'{col}', fontsize=16, fontweight='bold', pad=8)
        
        ax.locator_params(axis='x', nbins=4) 
        ax.tick_params(labelsize=9)

        ax.set_xlabel('Scaled Value' if i >= 6 else '', fontsize=12)
        ax.set_ylabel('Density' if i % 3 == 0 else '', fontsize=12)
        
        ax.get_legend().remove()
        ax.grid(True, linestyle='--', alpha=0.3, axis='both')
        sns.despine(ax=ax)
    
    plt.tight_layout()
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


def plot_compared_boxplots(combined_df, savepath=None):
    fig, axes = plt.subplots(3, 3, figsize=(12, 12))
    axes = axes.flatten()
    
    features = [col for col in combined_df.columns if col != 'Strategy']
    for i, col in enumerate(features):
        ax = axes[i]
        sns.boxplot(ax=ax, data=combined_df, x='Strategy', y=col,
                    hue='Strategy', palette=palette, width=0.5, legend=False)
        
        ax.set_title(f'{col}', fontsize=16, fontweight='bold', pad=8)
        
        ax.set_ylabel('Scaled Value' if i % 3 == 0 else '', fontsize=12)
        
        ax.set_xlabel('')
        ax.set_xticklabels([]) 
        ax.tick_params(labelsize=9)
        
        ax.grid(True, linestyle='--', alpha=0.3, axis='y')
        sns.despine(ax=ax)
        
    plt.tight_layout()
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


def cluster_diagnostics(X, param_grids: dict):
    """
    Evaluates clustering algorithms, generating diagnostic plots, 
    and exports a CSV of the best configurations and their performances.
    """    
    X_arr = X.values if isinstance(X, pd.DataFrame) else X
    
    x_param_keys = {
        'kmeans': 'n_clusters', 
        'agglomerative': 'n_clusters', 
        'dbscan': 'min_samples', 
        'hdbscan': 'min_cluster_size'
    }
    
    all_results = []
    best_configs = {}  
    best_performances = []
    for alg, param_grid in param_grids.items():
        alg = alg.lower()
        if alg not in clustering_dict:
            print(f"[WARNING] Algorithm '{alg}' not supported. Skipping.")
            continue
            
        grid = list(ParameterGrid(param_grid))
        x_col = x_param_keys.get(alg, 'n_clusters')
        algo_results = []
        
        for params in grid:
            model = clustering_dict[alg](**params)
            labels = model.fit_predict(X_arr)
            
            mask = labels != -1
            n_valid_clusters = len(set(labels[mask]))
            
            if n_valid_clusters >= 2:
                sil = silhouette_score(X_arr[mask], labels[mask])
                db = davies_bouldin_score(X_arr[mask], labels[mask])
            else:
                sil, db = np.nan, np.nan
                
            x_val = params.get(x_col, n_valid_clusters)
            
            group_params = {k: v for k, v in params.items() if k != x_col}
            legend_str = ", ".join([f"{k}={v}" for k, v in group_params.items()])
            if not legend_str:
                legend_str = "Base Config"
            
            param_str_full = ", ".join([f"{k}={v}" for k, v in params.items()])
                
            result_dict = {
                "Method": alg.upper(),
                "Config_Legend": legend_str,
                "Configuration": f"{alg.upper()} ({param_str_full})",
                "Raw_Params": params,
                "X_Value": x_val,
                "Num_Clusters": n_valid_clusters,
                "Silhouette_Score": sil,
                "Davies_Bouldin_Index": db
            }
            algo_results.append(result_dict)
            all_results.append(result_dict)
            
        df_algo = pd.DataFrame(algo_results)
        df_valid = df_algo.dropna(subset=["Silhouette_Score", "Davies_Bouldin_Index"]).reset_index(drop=True)

        if df_valid.empty:
            print(f"[WARNING] No valid clusters for {alg.upper()}. Skipping plot.")
            continue
            
        fig, axes = plt.subplots(1, 2, figsize=(15, 6), constrained_layout=True)
        
        x_label_display = x_col if x_col else "Number of Clusters"

        groups = df_valid.groupby("Config_Legend")
        colors = itertools.cycle(plt.cm.tab20.colors)
        markers = itertools.cycle(['o', 's', '^', 'D', 'v', 'p', '*', 'X', 'h', '<', '>'])
        
        legend_handles, legend_labels = [], []

        for legend_label, df_group in groups:
            df_group = df_group.sort_values("X_Value")
            marker = next(markers)
            color = next(colors)
            
            line1, = axes[0].plot(df_group["X_Value"], df_group["Silhouette_Score"], 
                                  marker=marker, color=color, linestyle='-', linewidth=2, markersize=7)
            axes[1].plot(df_group["X_Value"], df_group["Davies_Bouldin_Index"], 
                         marker=marker, color=color, linestyle='-', linewidth=2, markersize=7)
            
            legend_handles.append(line1)
            legend_labels.append(legend_label)

        axes[0].set_ylabel("Silhouette Score", fontsize=12, fontweight="bold")
        axes[0].set_xlabel(x_label_display, fontsize=11)
        axes[0].grid(True, linestyle='--', alpha=0.6)
        axes[0].xaxis.set_major_locator(MaxNLocator(integer=True))
        
        axes[1].set_ylabel("Davies-Bouldin Index", fontsize=12, fontweight="bold")
        axes[1].set_xlabel(x_label_display, fontsize=11)
        axes[1].grid(True, linestyle='--', alpha=0.6)
        axes[1].xaxis.set_major_locator(MaxNLocator(integer=True))

        fig.legend(legend_handles, legend_labels, title="Configurations", 
                   bbox_to_anchor=(1.01, 0.5), loc='center left', borderaxespad=0.)
            
        plt.savefig(f"images/diagnostic_{alg}.png", bbox_inches='tight', dpi=300)
        plt.close()

        df_valid['Rank_Sil'] = df_valid['Silhouette_Score'].rank(ascending=False)
        df_valid['Rank_DB'] = df_valid['Davies_Bouldin_Index'].rank(ascending=True)
        df_valid['Total_Rank'] = df_valid['Rank_Sil'] + df_valid['Rank_DB']
        
        best_consensus = df_valid.loc[df_valid['Total_Rank'].idxmin()]
        best_configs[alg] = best_consensus['Raw_Params']

        config_name = f"{alg.upper()} - {best_consensus['Raw_Params']}"
        best_performances.append({
            'Algorithm_Configuration': config_name,
            'Silhouette_Score': round(best_consensus['Silhouette_Score'], 3),
            'Rank_Sil': int(best_consensus['Rank_Sil']),
            'Davies_Bouldin_Index': round(best_consensus['Davies_Bouldin_Index'], 3),
            'Rank_DB': int(best_consensus['Rank_DB']),
            'Valid_Clusters': int(best_consensus['Num_Clusters'])
        })

    if best_performances:
        df_perf = pd.DataFrame(best_performances).set_index('Algorithm_Configuration')
        df_perf.to_csv("data/best_algo.csv")


    df_all_results = pd.DataFrame(all_results).dropna(subset=["Silhouette_Score", "Davies_Bouldin_Index"])    

    metrics_list = ['Silhouette_Score', 'Davies_Bouldin_Index']
    unique_methods = df_all_results['Method'].unique()
    algo_palette = sns.color_palette("Set2", n_colors=len(unique_methods))    
    for metric in metrics_list:
        fig, ax = plt.subplots(figsize=(10, 6), constrained_layout=True)
        
        sns.boxplot(
            data=df_all_results, x='Method', y=metric, hue='Method', legend=False,
            ax=ax, palette=algo_palette, boxprops=dict(alpha=0.3), linewidth=1.5, fliersize=0
        )
        
        sns.stripplot(
            data=df_all_results, x='Method', y=metric, hue='Method', legend=False,
            jitter=0.2, s=7, alpha=0.8, palette=algo_palette, ax=ax, edgecolor='gray', linewidth=0.5
        )
        
        clean_metric_name = metric.replace("_", " ")
        ax.set_ylabel(clean_metric_name, fontsize=12, fontweight='bold')
        ax.grid(True, linestyle='--', alpha=0.4)
        
        if metric == 'Silhouette_Score':
            ax.set_ylim(-0.05, 1.0)
            
        plt.savefig(f'images/comparison_{metric.lower()}.png', dpi=300, bbox_inches='tight')
        plt.close()
        
    return best_configs, df_all_results


def plot_proximity_matrices(X, labels_dict, metric='euclidean', max_samples=1500, savepath=None):
    """
    Plots the Proximity (Distance) Matrix sorted by cluster labels for multiple algorithms.
    Generates a single row of heatmaps with no titles and consistent coloring.
    """
    X_arr = X.values if isinstance(X, pd.DataFrame) else X
    
    if len(X_arr) > max_samples:
        print(f"Dataset too large for N x N matrix. Subsampling to {max_samples} points...")
        np.random.seed(42)
        idx = np.random.choice(len(X_arr), max_samples, replace=False)
        X_arr = X_arr[idx]
        labels_dict = {name: np.array(lbls)[idx] for name, lbls in labels_dict.items()}
    else:
        labels_dict = {name: np.array(lbls) for name, lbls in labels_dict.items()}

    base_dist_matrix = squareform(pdist(X_arr, metric=metric))
    vmin, vmax = base_dist_matrix.min(), base_dist_matrix.max()
    num_algos = len(labels_dict)
    fig, axes = plt.subplots(1, num_algos, figsize=(6 * num_algos, 6), constrained_layout=True)
        
    for i, (ax, (algo_name, labels)) in enumerate(zip(axes, labels_dict.items())):
        sort_idx = np.argsort(np.where(labels == -1, np.inf, labels))
        sorted_dist_matrix = base_dist_matrix[sort_idx, :][:, sort_idx]

        show_cbar = (i == num_algos - 1)        
        sns.heatmap(sorted_dist_matrix, ax=ax, cmap='viridis_r', 
                    vmin=vmin, vmax=vmax,
                    cbar=show_cbar, 
                    cbar_kws={'label': f'{metric.capitalize()} Distance'} if show_cbar else None,
                    xticklabels=False, yticklabels=False)
        
        ax.set_xlabel(algo_name.upper(), fontsize=12, fontweight='bold', labelpad=10)
        
        if i == 0:
            ax.set_ylabel("Sorted Data Points", fontsize=11)
    
    if savepath:
        plt.savefig(savepath, dpi=300, bbox_inches='tight')
    plt.close()


world_url = "https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip"
world_gdf = gpd.read_file(world_url)

world_gdf["iso_a3"] = world_gdf["ISO_A3"].where(world_gdf["ISO_A3"] != "-99", world_gdf["ADM0_A3"])
world_gdf.loc[world_gdf["NAME"] == "France", "iso_a3"] = "FRA"
world_gdf.loc[world_gdf["NAME"] == "Norway", "iso_a3"] = "NOR"
world_gdf = world_gdf[world_gdf["NAME"] != "Antarctica"]


def run_clustering_and_map(alg: str, alg_params: dict, X, countries_input): 
    """
    Fits the specified algorithm, computes a 2D t-SNE projection if needed,
    and displays separate geographical and scatter plots.
    """
    alg = alg.lower()
    X_arr = X.values if isinstance(X, pd.DataFrame) else X

    clustering = clustering_dict[alg](**alg_params).fit(X_arr)
    labels = clustering.labels_
    if X_arr.shape[1] > 2:
        perp = min(30, max(5, len(X_arr) // 5))
        X_vis = TSNE(n_components=2, perplexity=perp, random_state=42).fit_transform(X_arr)
    else:
        X_vis = X_arr

    sample_countries = list(countries_input)
    if sample_countries and len(str(sample_countries[0])) == 3 and str(sample_countries[0]).isupper():
        merge_key = "iso_a3"
    else:
        merge_key = "NAME"

    df_results = pd.DataFrame({merge_key: countries_input, "cluster": labels})
    
    if merge_key == "NAME":
        country_name_fixes = {
            "United States": "United States of America",
            "US": "United States of America",
            "USA": "United States of America",
            "UK": "United Kingdom"
        }
        df_results["NAME"] = df_results["NAME"].replace(country_name_fixes)

    world_merged = world_gdf.merge(df_results, on=merge_key, how="left")

    # PLOT 1: tSNE Projection
    fig_tsne, ax_tsne = plt.subplots(figsize=(10, 8))
    scatter = ax_tsne.scatter(X_vis[:, 0], X_vis[:, 1], c=labels, cmap='tab10', edgecolor='k', s=70, alpha=0.9)
    ax_tsne.grid(True, linestyle='--', alpha=0.5)

    plt.xlabel('t-SNE Component 1')
    plt.ylabel('t-SNE Component 2')
    plt.savefig(f"images/{alg}_tsne.png", dpi=300, bbox_inches='tight')
    plt.close()

    # PLOT 2: Geographical World Map
    fig_map, ax_map = plt.subplots(figsize=(14, 7))
    world_gdf.plot(ax=ax_map, color="#e0e0e0", edgecolor="white", linewidth=0.5, aspect="equal")
    clustered_countries = world_merged.dropna(subset=["cluster"])

    if not clustered_countries.empty:
        clustered_countries.plot(
            column="cluster",
            ax=ax_map,
            categorical=True,
            cmap="tab10",
            edgecolor="white",
            linewidth=0.5,
            legend=True,
            aspect="equal",
            legend_kwds={"title": "Clusters", "loc": "lower left", "frameon": True}
        )
    else:
        ax_map.text(0.5, 0.5, "Data Match Failed!\nCheck country list formatting.", 
                    transform=ax_map.transAxes, ha="center", va="center", color="red", fontsize=14, weight="bold")
        print(f"\n[WARNING]: 0 countries matched for {alg.upper()}. Map will render blank.")

    ax_map.set_axis_off()
    
    plt.savefig(f"images/{alg}_map.png", dpi=300, bbox_inches='tight')
    plt.close()
    
    return clustering


def discover_causal_dag(X_df, alpha=0.05):
    """
    Uses the PC algorithm to discover a causal DAG from continuous observational data.
    Generates a network plot of the discovered causal relationships.
    """
    if not isinstance(X_df, pd.DataFrame):
        print("[ERROR] Please provide a Pandas DataFrame with column names.")
        return None
        
    df_clean = X_df.dropna()
    if len(df_clean) < len(X_df):
        print(f"[WARNING] Dropped {len(X_df) - len(df_clean)} rows containing NaNs.")
    
    estimator = PC(data=df_clean)
    dag = estimator.estimate(
        return_type='dag', 
        variant='stable', 
        ci_test='pearsonr', 
        significance_level=alpha,
        show_progress=False
    )
    
    edges = list(dag.edges())
    print(f"Discovery Complete: Found {len(edges)} directed edges.")
    
    G = nx.DiGraph()
    G.add_nodes_from(df_clean.columns)
    G.add_edges_from(edges)
    
    try:
        layers = list(nx.topological_generations(G))
    except nx.NetworkXUnfeasible:
        print("[WARNING] Graph contains cycles. Falling back to spring layout.")
        layers = [list(G.nodes())]

    pos = {}
    for layer_idx, nodes in enumerate(layers):
        x_coords = np.linspace(-1, 1, len(nodes)) if len(nodes) > 1 else [0]
        for node, x in zip(nodes, x_coords):
            pos[node] = (x, -layer_idx)


    fig, ax = plt.subplots(figsize=(14, 10))
    
    nx.draw_networkx_nodes(
        G, pos, ax=ax, 
        node_color='#f6f8fa', 
        node_size=3200, 
        edgecolors='#24292e', 
        linewidths=1.5
    )
    
    nx.draw_networkx_labels(G, pos, ax=ax, font_size=9, font_weight='bold', font_color='#24292e')
    
    nx.draw_networkx_edges(
        G, pos, ax=ax, 
        edge_color='#57606a', 
        arrows=True, 
        arrowstyle='-|>',
        arrowsize=20, 
        node_size=3200, 
        connectionstyle="arc3,rad=0.15",
        width=1.5
    )
    
    ax.set_title(f"Discovered Causal Hierarchy (PC Algorithm, $\\alpha$={alpha})\nRoots/Causes $\\rightarrow$ Leaf/Effects", 
                 fontsize=14, fontweight='bold', pad=20)
    
    ax.set_axis_off()
    x_values = [coords[0] for coords in pos.values()]
    y_values = [coords[1] for coords in pos.values()]
    ax.set_xlim(min(x_values) - 0.5, max(x_values) + 0.5)
    ax.set_ylim(min(y_values) - 0.5, max(y_values) + 0.5)
    
    plt.savefig(f"images/causal_dag.png", dpi=300, bbox_inches='tight')
    plt.close()
    
    return dag

if __name__ == "__main__":
    clustering_dict = {
        'kmeans': KMeans,
        'agglomerative': AgglomerativeClustering,
        'hdbscan': HDBSCAN
    }

    param_grids = {
        'kmeans': {
            'n_clusters': list(range(2, 11)),
            'init': ['k-means++', 'random'],
            'algorithm': ['lloyd', 'elkan'],
            'random_state': [42]  
        },
        
        'agglomerative': [
            {
                'n_clusters': list(range(2, 11)),
                'linkage': ['ward'],
                'metric': ['euclidean']
            },
            {
                'n_clusters': list(range(2, 11)),
                'linkage': ['complete'],
                'metric': ['euclidean', 'manhattan']
            }
        ],

        'hdbscan': {
            'min_cluster_size': [3, 5, 6, 7, 8, 12],  
            'cluster_selection_method': ['eom', 'leaf'],
            'metric': ['euclidean', 'manhattan']
        }
    }

    alpha = 0.1

    df = pd.read_csv("data/data.csv")
    countries = df['country']
    df_num = df.drop('country', axis=1)

    plot_distributions(df_num, "images/distributions.png")
    plot_correlations(df_num, "images/correlations.png")
    plot_scatter(df_num, "images/scatter.png")

    plot_tsne(df_num, countries,  perplexity=10, savepath="images/tsne.png")

    ss = StandardScaler()
    X_std = ss.fit_transform(df_num)
    df_std = pd.DataFrame(X_std, columns=df_num.columns)
    plot_distributions(df_std, "images/distributions_std.png")

    pt = PowerTransformer()
    X_pwr = pt.fit_transform(df_num)
    df_pwr = pd.DataFrame(X_pwr, columns=df_num.columns)

    plot_distributions(df_pwr, "images/distributions_pwr.png")
    plot_correlations(df_pwr, "images/correlations_pwr.png")

    df_std_labeled = df_std.copy().assign(Strategy='Standard Scaling')
    df_pwr_labeled = df_pwr.copy().assign(Strategy='Power Transform')
    combined_df = pd.concat([df_std_labeled, df_pwr_labeled], axis=0)
    plot_compared_boxplots(combined_df, savepath='images/comparison_boxplots.png')
    plot_compared_distributions(combined_df, savepath='images/comparison_distributions.png')


    best_params, all_results_df = cluster_diagnostics(X=X_pwr, param_grids=param_grids)

    best_algos = {}
    best_labels = {}
    for algo_name, params in best_params.items(): 
        fitted_model = run_clustering_and_map(
            alg=algo_name,
            alg_params=params,
            X=X_pwr,
            countries_input=countries 
        )
        
        labels = fitted_model.labels_
        best_labels[algo_name] = labels
        best_algos[algo_name] = fitted_model
        
        df_raw_labeled = df.copy()
        df_raw_labeled['Cluster'] = labels
        
        centroids = df_raw_labeled[df_raw_labeled['Cluster'] != -1].groupby('Cluster').mean(numeric_only=True).round(3)
        
        total_obs = len(df_raw_labeled)
        percentages = (df_raw_labeled['Cluster'].value_counts() / total_obs * 100).round(2)
        centroids['PCT'] = percentages
        
        file_name = f"data/{algo_name}_centroids.csv"
        centroids.to_csv(file_name, index=True) 

    plot_proximity_matrices(X_pwr, best_labels, savepath="images/proximity_matrices.png")

    causal_model = discover_causal_dag(X_df=df_pwr, alpha=alpha)