using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class SmoothNormals : MonoBehaviour
{
    private void Awake()
    {
        // 获取模型的网格数据
        Mesh mesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;

        // 使用 LINQ 查询将顶点按其位置分组，以便后续计算平滑法线
        IEnumerable<IEnumerable<KeyValuePair<Vector3, int>>>
            groups = mesh.vertices.Select(
                (vertex, index) => new KeyValuePair<Vector3, int>(vertex, index)).GroupBy(pair => pair.Key);

        // 获取原始法线数据
        Vector3[] normals = mesh.normals;

        // 创建一个新的数组以存储平滑法线，使用Vector4以与mesh.tangents兼容
        Vector4[] smoothNormals = normals.Select((normal, index) => new Vector4(normal.x, normal.y, normal.z)).ToArray();

        // 遍历每个顶点分组
        foreach (var group in groups)
        {
            // 如果顶点仅出现一次，不需要平滑法线
            if (group.Count() == 1)
            {
                continue;
            }

            // 初始化平滑法线向量
            Vector3 smoothNormal = Vector3.zero;

            // 遍历组内的顶点，累加其法线
            foreach (var pair in group)
                smoothNormal += normals[pair.Value];

            // 归一化平滑法线向量
            smoothNormal.Normalize();

            // 将计算的平滑法线赋给每个组内的顶点
            foreach (var pair in group)
                smoothNormals[pair.Value] = new Vector4(smoothNormal.x, smoothNormal.y, smoothNormal.z);
        }

        // 将计算的平滑法线数据应用于模型的切线数据（tangents）
        mesh.tangents = smoothNormals;
        Debug.Log("--------------------------------------");
    }
}

/*using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class SmoothNormals : MonoBehaviour
{
    private void Awake()
    {
        Mesh mesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;

        Dictionary<Vector3, List<int>> vertexToIndex = new Dictionary<Vector3, List<int>>();
        Vector3[] smoothNormals = new Vector3[vertices.Length];

        // 初始化平滑法线
        for (int i = 0; i < smoothNormals.Length; i++)
        {
            smoothNormals[i] = Vector3.zero;
        }

        // 遍历每个顶点，将它们按其位置分组
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertex = vertices[i];
            if (!vertexToIndex.ContainsKey(vertex))
            {
                vertexToIndex[vertex] = new List<int>();
            }
            vertexToIndex[vertex].Add(i);
        }

        // 遍历每个顶点分组
        foreach (var group in vertexToIndex.Values)
        {
            if (group.Count == 1)
            {
                continue; // 顶点仅出现一次，无需平滑法线
            }

            // 计算平均法线
            Vector3 averageNormal = Vector3.zero;
            for (int i = 0; i < group.Count; i++)
            {
                averageNormal += normals[group[i]];
            }
            averageNormal /= group.Count;

            // 应用平均法线到每个顶点
            for (int i = 0; i < group.Count; i++)
            {
                smoothNormals[group[i]] = averageNormal;
            }
        }

        // 更新模型的法线和切线数据
        mesh.normals = smoothNormals;
        mesh.RecalculateNormals();
        mesh.tangents = tangents;
        Debug.Log("--------------------------------------");
    }
}*/


