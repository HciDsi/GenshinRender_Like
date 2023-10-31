using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmoothNormalsWeighted : MonoBehaviour
{
    private void Awake()
    {
        Mesh mesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;

        // 创建一个字典以存储每个顶点的加权平均法线
        Dictionary<Vector3, Vector3> smoothNormals = new Dictionary<Vector3, Vector3>();

        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertex = vertices[i];
            Vector3 normal = normals[i];

            if (smoothNormals.ContainsKey(vertex))
            {
                // 如果顶点已经在字典中，则累加法线
                smoothNormals[vertex] += normal;
            }
            else
            {
                // 否则，在字典中创建一个新条目
                smoothNormals[vertex] = normal;
            }
        }

        // 更新切线数据以存储平滑法线
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertex = vertices[i];
            Vector3 smoothNormal = smoothNormals[vertex].normalized;

            // 更新切线数据
            tangents[i] = new Vector4(smoothNormal.x, smoothNormal.y, smoothNormal.z, 1f);
        }

        // 将更新后的切线数据应用到网格
        mesh.tangents = tangents;
    }
}
